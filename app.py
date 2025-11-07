from flask import Flask, flash, redirect, url_for, render_template, request, session

from flask_session import Session
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import mysql.connector


app = Flask(__name__)
app.secret_key = 'clave_secreta_prueba'
app.config['SESSION_TYPE'] = 'filesystem'
Session(app)


import mysql.connector

# Diccionario de configuración
db_config = {
    'host': 'localhost',
    'user': 'AhorrApp',
    'password': 'password',
    'database': 'proyecto'
}



# Función que usa ese diccionario
def conectar_db():
    return mysql.connector.connect(**db_config)


db_connection = mysql.connector.connect(**db_config)
cursor = db_connection.cursor()

def get_db_connection():
    return mysql.connector.connect(**db_config)


# ------------------------------------------------------------------------------------------------

@app.route('/')
def index():
    return render_template ('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        contrasena = request.form.get('password')

        if not email or not contrasena:
            flash('Por favor completa todos los campos.', 'danger')
            return redirect(url_for('login'))

        conn = None
        cursor = None

        try:
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor(dictionary=True)

            # Buscar usuario por email
            cursor.execute('SELECT * FROM usuarios WHERE email = %s', (email,))
            usuario = cursor.fetchone()

            # Verificar si existe y si la contraseña es correcta
            if usuario and check_password_hash(usuario['contrasena'], contrasena):
                session['logged_in'] = True
                session['username'] = usuario['nombre']
                session['useremail'] = usuario['email']
                session['user_id'] = usuario['id']

                flash('Inicio de sesión exitoso.', 'success')
                return redirect(url_for('index'))
            else:
                flash('Correo o contraseña incorrectos.', 'danger')
                return redirect(url_for('login'))

        except mysql.connector.Error as err:
            flash(f'Error al conectar a la base de datos: {err}', 'danger')

        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    return render_template('login.html')



@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        nombre = request.form['nombre']
        email = request.form['email']
        contrasena = request.form['password']

        # Validar campos vacíos
        if not nombre or not email or not contrasena:
            flash('Todos los campos son obligatorios.', 'danger')
            return redirect(url_for('register'))

        conexion = conectar_db()
        cursor = conexion.cursor()

        try:
            # Verificar si el correo ya está registrado
            cursor.execute("SELECT id FROM usuarios WHERE email = %s", (email,))
            if cursor.fetchone():
                flash('El email ya está registrado.', 'danger')
                return redirect(url_for('register'))

            # Encriptar la contraseña
            hashed_password = generate_password_hash(contrasena)

            # Insertar nuevo usuario
            cursor.execute(
                "INSERT INTO usuarios (nombre, email, contrasena) VALUES (%s, %s, %s)",
                (nombre, email, hashed_password)
            )
            conexion.commit()
            # flash('Usuario registrado correctamente.', 'success')
            return redirect(url_for('login'))

        except Exception as e:
            conexion.rollback()
            # flash('Error al registrar usuario: ' + str(e), 'danger')

        finally:
            cursor.close()
            conexion.close()

    return render_template('register.html')

@app.route('/logout')
def logout():
    session.pop('logged_in', None)
    session.pop('username', None)
    session.pop('useremail', None)
    # flash('Has cerrado sesión exitosamente', 'success')
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)