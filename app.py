from flask import Flask, request, jsonify
import tensorflow as tf
from flask_cors import CORS
from supabase import create_client, Client

app = Flask(__name__)
CORS(app)

model = tf.saved_model.load(r'C:\recommender_app\weforshe-model-demo')

@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        data = request.json
        user_id = data['user_id']
        gender = data['gender']

        scores, recommendations = model([user_id])
        temp = recommendations.numpy().tolist()[0]
        result = []
        for i in temp:
            result.append(str(i)[2:-1])
        print(recommendations[0, :3], "recommendations")

        print(test_connection())
        top_category = fetch_and_analyze_reviews('Women')
        print(top_category)

        return jsonify(result)
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
    response = supabase.from_("results").select("*").order("percentage", desc=True).execute()

    reviews = response.data
#     print(reviews, "reviews")

    gender_filtered_reviews = [review for review in reviews if review['gender'] == gender]

    if not gender_filtered_reviews:
        return "No data available"

    top_category = gender_filtered_reviews[0]['option']

    return top_category

if __name__ == '__main__':
  app.run(debug=True)
