<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Raleway|Ubuntu" rel="stylesheet">

    <!-- Estilos -->
    <link rel="stylesheet" href="css/login.css">

  

    <title>Formulario Login y Registro de Usuarios</title>
</head>
<body>

   <!-- Formularios -->
    <div class="contenedor-formularios">
        <!-- Links de los formularios -->
        <h1 class="ocul" style="margin-top: 190px;"> Seleccione Tipo De Usuario </h1>
        <br>

        <ul class="contenedor-tabs">
            <li id ="ocultar" class="tab tab-segunda active" onClick="document.getElementById('iniciar-sesion').style.visibility='visible'"><a href="#iniciar-sesion">Persona</a></li>
            <li id ="ocultar2"class="tab tab-primera"><a href="#registrarse">Empresa</a></li>
        </ul>

        <!-- Contenido de los Formularios -->
        <div class="contenido-tab">
            <!-- Iniciar Sesion -->
            <div id="iniciar-sesion" style="visibility:hidden">
                <h1>Persona</h1>
                <form action="#" method="post">
                    <div class="contenedor-input">
                        <label>
                            Usuario <span class="req">*</span>
                        </label>
                        <input type="text" required>
                    </div>

                    <div class="contenedor-input">
                        <label>
                            Contraseña <span class="req">*</span>
                        </label>
                        <input type="password" required>
                    </div>

                    <div class="contenedor-input">
                        <label>
                            Nombre <span class="req">*</span>
                        </label>
                        <input type="text" required>
                    </div>

                     <div class="contenedor-input">
                        <label>
                           Correo <span class="req">*</span>
                        </label>
                        <input type="text" required>
                    </div>

                     <div class="contenedor-input">
                        <label>
                            DNI <span class="req">*</span>
                        </label>
                        <input type="text" required>
                    </div>

                     <div class="contenedor-input">
                        <label>
                            Telefono <span class="req">*</span>
                        </label>
                        <input type="text" required>
                    </div>

                     <div class="contenedor-input">
                        <label>
                            Dirección <span class="req">*</span>
                        </label>
                        <input type="text" required>
                    </div>
                    <br>
                    <p class="forgot"><a href="#">Tienes Cuenta ? Login </a></p>
                      <br>
                        <br>
                    <input type="submit" class="button button-block" value="Registrarse">
                </form>
            </div>


            <!-- Registrarse -->
            <div id="registrarse">
                <h1>Empresa</h1>
                <form action="#" method="post">
                    <div class="fila-arriba">
                        <div class="contenedor-input">
                            <label>
                                Usuario <span class="req">*</span>
                            </label>
                            <input type="text" required >
                        </div>

                        <div class="contenedor-input">
                            <label>
                                Contraseña <span class="req">*</span>
                            </label>
                            <input type="text" required>
                        </div>
                    </div>
                    <div class="contenedor-input">
                        <label>
                            Razón Social <span class="req">*</span>
                        </label>
                        <input type="text" required>
                    </div>
                    <div class="contenedor-input">
                            <label>
                                Ruc <span class="req">*</span>
                            </label>
                        <input type="email" required>
                    </div>
                    <div class="contenedor-input">
                        <label>
                            Correo <span class="req">*</span>
                        </label>
                        <input type="password" required>
                    </div>

                    <div class="contenedor-input">
                        <label>
                            Telefono <span class="req">*</span>
                        </label>
                        <input type="password" required>
                    </div>
                      <div class="contenedor-input">
                        <label>
                            Direccion <span class="req">*</span>
                        </label>
                        <input type="text" required>
                    </div>
                                        <br>
                    <p class="forgot"><a href="#">Tienes Cuenta ? Login </a></p>
                      <br>
                        <br>

                    <input type="submit" class="button button-block" value="Registrarse">
                </form>
            </div>
        </div>
    </div>


<script src="js/jquery-3.1.1.min.js"></script>
<script src="js/main.js"></script>


</body>
</html>