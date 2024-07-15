from flask import Flask, request, jsonify
import tensorflow as tf
from flask_cors import CORS
from supabase import create_client, Client
import pandas as pd

app = Flask(__name__)
CORS(app)

model = tf.saved_model.load(r'C:\recommender_app\myntra-recommender-model')

@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        data = request.json
        user_id = data['user_id']
        gender = data['gender']
        if gender == "Female":
            gender = "Women"
        elif gender == "Male":
            gender = "Men"
        print("User ID: ", user_id, "\nGender:", gender)

        scores, recommendations = model([user_id])
        temp = recommendations.numpy().tolist()[0]

        top_categories = fetch_and_analyze_reviews('Women')
        print("Top_category: ", top_categories)

        df = pd.read_csv('C:/recommender_app/assets/myntra-products.csv')
        result = []
        for rec in temp:
            product = str(rec)[2:-1]
            filtered_df = df[df['Description'] == product]

            if not filtered_df.empty:
                category = filtered_df['Individual_category'].iloc[0]
                product_gender = filtered_df['category_by_Gender'].iloc[0]

                if gender == product_gender and category in top_categories:
                    result.insert(0, product.title())
                elif gender == product_gender:
                    result.append(product.title())

        if (len(result) >= 10):
            recommend = result[:10]
        else:
            recommend = result

        return jsonify(recommend)
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 400

@app.route('/test_connection', methods=['GET'])
def test_connection():
    try:
        response = supabase.from_("results").select("*").limit(1).execute()
        return jsonify({"message": "Connected to Supabase successfully", "data": response.data})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

SUPABASE_URL = "https://mlqtdjmsspmsinudegsl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1scXRkam1zc3Btc2ludWRlZ3NsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjA4MDk2NjksImV4cCI6MjAzNjM4NTY2OX0.CP6Cvi8bCdaGduViiX6mMEhY_GbOSWzcxYAZL6n5rQU"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def fetch_and_analyze_reviews(gender):
    try:
        response = supabase.from_("results").select("*").order("percentage", desc=True).execute()
        reviews = response.data

        df_helper = pd.DataFrame(reviews)
        gender_filtered_reviews = df_helper[df_helper['gender'] == gender]
        top_categories = gender_filtered_reviews['product'].unique()[:3]

        return list(top_categories)
    except:
        return []

if __name__ == '__main__':
  app.run(debug=True)
