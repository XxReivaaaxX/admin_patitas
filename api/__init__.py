import firebase_admin
from flask import Flask, request, jsonify
from firebase_admin import  credentials,db, auth
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

cred = credentials.Certificate("Key.json")

# 
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://admin-patitas-default-rtdb.firebaseio.com/'})

@app.route('/submit', methods=['POST'])
def submit_data():
    try:
        data = request.get_json()

        name = data['name']
        email = data['email']


        ref = db.reference('prueba')
        new_email_ref = ref.push()
        new_email_ref.set({
            'name': name,
            'email': email
        })
        
        return jsonify({"message": "datos de prueba agregados correctamente"}), 200
    except Exception as e:
        print("ERROR EN LA EJECUCION DE LA API: {e}")
        return jsonify({"error": str(e)}), 500
    

@app.route('/register', methods=['POST'])
def user_register():
    try:
        data = request.get_json()
        print(data)

        
        email = data['email']
        password = data['password']


        auth.create_user(
            email=email,
            password=password
        )


        print("USUARIO CREADO CORRECTAMENTE: {user.uid}")
        return jsonify({"message": "usuario agregado correctamente"}), 200
    except Exception as e:
        print("ERROR EN LA EJECUCION DE LA API: ",e)
        return jsonify({"error": str(e)}), 500
    
if __name__ == '__main__':
    app.run(debug=True)
