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
    'password': 'Ah0rrApp_2026!',
    'database': 'SEproyectoNA'
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
# ======================================================================
# ------------------ PANEL GENERAL - ADMINISTRADOR ------------------
# ======================================================================
@app.route('/generalpanel')
def generalpanel():
        if 'logged_in' in session:
            # and session.get('rol') == 'Usuario':
            return render_template('generalpanel.html')
        return redirect(url_for('index.html'))

# --- PANEL DE USUARIOS ---
@app.route('/panelUser')
def panelUser():
    if 'logged_in' in session:
    # and session.get('rol') == 'Usuario':
        try:
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor(dictionary=True)
            cursor.execute('SELECT * FROM usuarios')
            usuarios = cursor.fetchall()
            return render_template('panelUser.html', usuarios=usuarios)
        except mysql.connector.Error as err:
            flash(f'Error: {err}', 'danger')
            return redirect(url_for('index')) 
        finally:
            cursor.close()
            conn.close()
    return redirect(url_for('login'))

@app.route('/panelMovements')
def panelMovements():
    if 'logged_in' in session:
        # and session.get('rol') == 0:
        try:
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor(dictionary=True)
            query_movimientos = """
                SELECT 
                    M.ID_movimiento, 
                    M.Subtipo_Modulo, 
                    M.Tipo_Flujo, 
                    M.Fecha_Creacion,

                    COALESCE(A.Monto, I.Monto, G.Monto, IMP.Monto, D.Monto) AS Monto,
                    COALESCE(A.Descripcion, I.Descripcion, G.Descripcion, D.Descripcion) AS Descripcion,
                    COALESCE(A.Fecha_registro, I.Fecha_registro, G.Fecha_registro, IMP.Fecha_registro, D.Fecha_inicio) AS Fecha_registro,

                    A.Meta, 
                    A.Fecha_meta, 

                    COALESCE(I.Fuente, D.Fuente) AS Fuente,
                    D.Estado, 
                    IMP.Causa
                FROM MOVIMIENTOS M
                LEFT JOIN ENTRADA E ON M.ID_movimiento = E.ID_movimiento
                LEFT JOIN SALIDA S ON M.ID_movimiento = S.ID_movimiento
                LEFT JOIN AHORROS A ON E.ID_entrada = A.ID_entrada
                LEFT JOIN INGRESOS I ON E.ID_entrada = I.ID_entrada
                LEFT JOIN GASTOS G ON S.ID_salida = G.ID_salida
                LEFT JOIN IMPREVISTOS IMP ON S.ID_salida = IMP.ID_salida
                LEFT JOIN DEUDAS D ON S.ID_salida = D.ID_salida
                ORDER BY M.Fecha_Creacion DESC
                """

            cursor.execute(query_movimientos)
            movimientos = cursor.fetchall()
            return render_template('panelMovements.html', movimientos=movimientos)
        except mysql.connector.Error as err:
            flash(f'Error: {err}', 'danger')
            return redirect(url_for('index')) 
        finally:
            cursor.close()
            conn.close()
    return redirect(url_for('login'))

# --- PANEL DE DEPENDIENTES ---
@app.route('/panelDependents')
def panelDependents():
    if 'logged_in' in session:
        # and session.get('rol') == 0:
        try:
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor(dictionary=True)
            query_dependientes = """
                SELECT D.*, U.nombre AS usuario_nombre 
                FROM DEPENDIENTES D
                INNER JOIN USUARIOS U ON D.ID_usuario = U.ID_usuario
            """
            cursor.execute(query_dependientes)
            dependientes = cursor.fetchall()
            return render_template('panelDependents.html', dependientes=dependientes)
        except mysql.connector.Error as err:
            flash(f'Error: {err}', 'danger')
            return redirect(url_for('index')) 
        finally:
            cursor.close()
            conn.close()
    return redirect(url_for('login'))

# --- PANEL DE HISTORIAL ---
@app.route('/panelHistory')
def panelHistory():
    if 'logged_in' in session:
        # and session.get('rol') == 0:
        try:
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor(dictionary=True)
            query_historial = """
                SELECT H.*, U.Nombre AS usuario_nombre 
                FROM HISTORIAL H
                INNER JOIN USUARIOS U ON H.ID_usuario = U.ID_usuario
                ORDER BY H.fecha DESC
            """
            cursor.execute(query_historial)
            historial = cursor.fetchall()
            return render_template('panelHistory.html', historial=historial)
        except mysql.connector.Error as err:
            flash(f'Error: {err}', 'danger')
            return redirect(url_for('index')) 
        finally:
            cursor.close()
            conn.close()
    return redirect(url_for('login'))

# ======================================================================
# ------------------ Login & Register (OF) ------------------
# ======================================================================
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        Password_hash = request.form.get('password')

        if not email or not Password_hash:
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
            if usuario and check_password_hash(usuario['Password_hash'], Password_hash):
                session['logged_in'] = True
                session['username'] = usuario['Nombre']
                session['useremail'] = usuario['Email']
                session['user_id'] = usuario['ID_usuario']

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
        nombre = request.form.get('nombre')
        email = request.form.get('email')
        password = request.form.get('password') 
        rol = 'Usuario' 

        if not nombre or not email or not password:
            flash('Todos los campos son obligatorios.', 'danger')
            return redirect(url_for('register'))

        conexion = conectar_db()
        cursor = conexion.cursor()

        try:
            cursor.execute("SELECT ID_usuario FROM USUARIOS WHERE Email = %s", (email,))
            if cursor.fetchone():
                flash('El email ya está registrado.', 'danger')
                return redirect(url_for('register'))

            hashed_pw = generate_password_hash(password)

            sql = """INSERT INTO USUARIOS (Nombre, Email, Password_hash, Rol) 
                     VALUES (%s, %s, %s, %s)"""
            cursor.execute(sql, (nombre, email, hashed_pw, rol))
            
            conexion.commit()
            flash('Registro exitoso. ¡Inicia sesión!', 'success')
            return redirect(url_for('login'))

        except Exception as e:
            conexion.rollback()
            flash(f'Error en el servidor: {str(e)}', 'danger')
        finally:
            cursor.close()
            conexion.close()

    return render_template('register.html')

# ======================================================================
# ------------------ Logout ------------------
# ======================================================================
@app.route('/logout')
def logout():
    session.pop('logged_in', None)
    session.pop('username', None)
    session.pop('useremail', None)
    # flash('Has cerrado sesión exitosamente', 'success')
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)