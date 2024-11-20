from flask import Flask, jsonify, request
import boto3
import os

app = Flask(__name__)

# Environment variables for S3
BUCKET_NAME = os.getenv('BUCKET_NAME', 'one2nbucketlisting')

s3_client = boto3.client('s3')

@app.route('/list-bucket-content/', defaults={'path': ''}, methods=['GET'])
@app.route('/list-bucket-content/<path:path>', methods=['GET'])
def list_bucket_content(path):
    try:
        prefix = f"{path}/" if path and not path.endswith('/') else path
        
        # Fetch objects and common prefixes from S3
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix=prefix, Delimiter='/')

        if 'Contents' not in response and 'CommonPrefixes' not in response:
            return jsonify({"error": f"The specified path '{prefix}' does not exist in the bucket."}), 404

        # Collect directories and files
        directories = [
            item['Prefix'].rstrip('/').split('/')[-1] for item in response.get('CommonPrefixes', [])]
        files = [
            item['Key'].split('/')[-1]
            for item in response.get('Contents', [])
            if item['Key'] != prefix  # Avoid including the directory itself
        ]

        # Combine results
        content = directories + files
        return jsonify({"content": content}), 200
    except s3_client.exceptions.NoSuchBucket:
        return jsonify({"error": "Bucket does not exist"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=443, ssl_context=('/server-cert.pem', '/server-key.pem'))
