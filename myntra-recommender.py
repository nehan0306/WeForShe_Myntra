import pandas as pd
import numpy as np
import tensorflow as tf
import tensorflow_recommenders as tfrs
from typing import Dict, Text

path = '/content/drive/MyDrive/myntra-hackathon/Myntra-fashion-dataset.csv'

data = pd.read_csv(path, low_memory=False)
data = data.dropna()

df_products = data[['category_by_Gender', 'Ratings', 'Description']]

num_duplicates = np.random.randint(1, 6, size=len(df_products))
product_indices = np.repeat(df_products.index, num_duplicates)
customer_ids = np.random.randint(1000, 9999, size=len(product_indices))
df_purchases = df_products.loc[product_indices].reset_index(drop=True)
df_purchases['customer_id'] = customer_ids
df_purchases['customer_id'] = df_purchases['customer_id'].astype('str')
df_purchases = df_purchases.sample(frac=1, random_state=42)

purchase_df = df_purchases.sample(40000)

purchase = tf.data.Dataset.from_tensor_slices({
    "customer_id": purchase_df["customer_id"],
    "category_by_Gender": purchase_df["category_by_Gender"],
    "Description": purchase_df["Description"],
})

purchase = purchase.map(lambda x: {
    "customer_id": x["customer_id"],
    "category_by_Gender": x["category_by_Gender"],
    "Description": x["Description"],
})

for i in purchase.take(1):
  print(i)

items_dict = purchase_df[['Description']].drop_duplicates()
items_dict = {name: np.array(value) for name, value in items_dict.items()}
items = tf.data.Dataset.from_tensor_slices(items_dict)
items = items.map(lambda x: x['Description'])

for i in items.take(1):
  print(i)

unique_user_ids = np.unique(np.concatenate(list(purchase.batch(1_000).map(lambda x: x["customer_id"]))))
unique_gender = np.unique(np.concatenate(list(purchase.batch(1_000).map(lambda x: x["category_by_Gender"]))))
unique_products = np.unique(np.concatenate(list(purchase.batch(1_000).map(lambda x: x["Description"]))))

tf.random.set_seed(42)
shuffled = purchase.shuffle(100_000, seed=42, reshuffle_each_iteration=False)

train = shuffled.take(int(len(purchase_df)*0.8))
test = shuffled.skip(int(len(purchase_df)*0.8)).take(int(len(purchase_df)*0.2))

class UserModel(tf.keras.Model):

    def __init__(self):
        super().__init__()

        self.user_embedding = tf.keras.Sequential([
            tf.keras.layers.experimental.preprocessing.StringLookup(
                vocabulary=unique_user_ids, mask_token=None),
            tf.keras.layers.Embedding(len(unique_user_ids) + 1, 32),
        ])

        self.gender_embedding = tf.keras.Sequential([
            tf.keras.layers.experimental.preprocessing.StringLookup(
                vocabulary=unique_gender, mask_token=None),
            tf.keras.layers.Embedding(len(unique_gender) + 1, 32),
        ])

    def call(self, inputs):
        return tf.concat([
            self.user_embedding(inputs["customer_id"]),
            self.gender_embedding(inputs["category_by_Gender"]),
        ], axis=1)


class QueryModel(tf.keras.Model):

    def __init__(self, layer_sizes):
        super().__init__()
        self.embedding_model = UserModel()

        self.dense_layers = tf.keras.Sequential()

        for layer_size in layer_sizes[:-1]:
            self.dense_layers.add(tf.keras.layers.Dense(layer_size, activation="relu"))

        for layer_size in layer_sizes[-1:]:
            self.dense_layers.add(tf.keras.layers.Dense(layer_size))

    def call(self, inputs):
        feature_embedding = self.embedding_model(inputs)
        return self.dense_layers(feature_embedding)


class ItemModel(tf.keras.Model):

    def __init__(self):
        super().__init__()

        self.title_embedding = tf.keras.Sequential([
          tf.keras.layers.experimental.preprocessing.StringLookup(
              vocabulary=unique_products, mask_token=None),
          tf.keras.layers.Embedding(len(unique_products) + 1, 32)
        ])


    def call(self, titles):
        return self.title_embedding(titles)

class CandidateModel(tf.keras.Model):

    def __init__(self, layer_sizes):

        super().__init__()

        self.embedding_model = ItemModel()

        self.dense_layers = tf.keras.Sequential()

        for layer_size in layer_sizes[:-1]:
            self.dense_layers.add(tf.keras.layers.Dense(layer_size, activation="relu"))

        for layer_size in layer_sizes[-1:]:
            self.dense_layers.add(tf.keras.layers.Dense(layer_size))

    def call(self, inputs):
        feature_embedding = self.embedding_model(inputs)
        return self.dense_layers(feature_embedding)

class ProductModel(tfrs.models.Model):

    def __init__(self, layer_sizes):
        super().__init__()
        self.query_model = QueryModel(layer_sizes)
        self.candidate_model = CandidateModel(layer_sizes)
        self.task = tfrs.tasks.Retrieval(
            metrics=tfrs.metrics.FactorizedTopK(
                candidates=items.batch(128).map(self.candidate_model),
            ),
        )

    def compute_loss(self, features, training=False):
        query_embeddings = self.query_model({
                "customer_id": features["customer_id"],
                "category_by_Gender": features["category_by_Gender"],
        })
        item_embeddings = self.candidate_model(features["Description"])

        return self.task(query_embeddings, item_embeddings, compute_metrics=not training)

model = ProductModel([16, 16])
model.compile(optimizer=tf.keras.optimizers.Adagrad(0.001), run_eagerly=True)

cached_train = train.shuffle(100_000).batch(516).cache()
cached_test = test.batch(1024).cache()

model.fit(cached_train, epochs=50)
model.evaluate(cached_test, return_dict=True)


index = tfrs.layers.factorized_top_k.BruteForce(model.user_model, k=50)
index.index_from_dataset(
  tf.data.Dataset.zip((items.batch(100), items.batch(100).map(model.item_model)))
)

user_id = "4565"
_, titles = index(tf.constant([user_id]))
print(f"Recommendations for user {user_id}: \n{titles[0, :5]}")

path = '/content/model'
tf.saved_model.save(index, path)

loaded_model = tf.saved_model.load(path)
scores, titles = loaded_model(["7834"])
print(f"Loaded recommendations: {titles[0][:5]}")



