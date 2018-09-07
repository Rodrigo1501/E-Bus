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
                <form action="Guardarregistro.php" method="post">
                    <input type="text" style="visibility:hidden" value="persona">
                    <div class="contenedor-input">
                        <label>
                            Usuario <span class="req">*</span>
                        </label>
                        <input type="text" pattern="[A-Za-z0-9.]{1,20}" name="usu" required>
                    </div>

                    <div class="contenedor-input">
                        <label>
                            Contraseña <span class="req">*</span>
                        </label>
                        <input type="password" pattern="[A-Za-z0-9.]{1,20}" name="contra" required>
                    </div>

                    <div class="contenedor-input">
                        <label>
                            Nombre <span class="req">*</span>
                        </label>
                        <input type="text" pattern="[A-Za-z]{1,60}" name="nom" required>
                    </div>

                                       <div class="contenedor-input">
                        <label>
                            Apellido <span class="req">*</span>
                        </label>
                        <input type="text" pattern="[A-Za-z]{1,60}" name="ape" required>
                    </div>

                     <div class="contenedor-input">
                        <label>
                           Correo <span class="req">*</span>
                        </label>
                        <input type="email" name="cor" required>
                    </div>

                     <div class="contenedor-input">
                        <label>
                            DNI <span class="req">*</span>
                        </label>
                        <input type="text" pattern="[0-9]{8}" name="dni" required>
                    </div>

                     <div class="contenedor-input">
                        <label>
                            Telefono <span class="req">*</span>
                        </label>
                        <input type="text" pattern="[0-9]{7}" name="tel" required>
                    </div>

                     <div class="contenedor-input">
                        <label>
                            Dirección <span class="req">*</span>
                        </label>
                        <input type="text"  name="dir" required>
                    </div>
                    <br>
                    <p class="forgot"><a href="index.php">Tienes Cuenta ? Login </a></p>
                      <br>
                        <br>
                    <input type="submit" class="button button-block" value="Registrarse">
                </form>
            </div>


            <!-- Registrarse -->
            <div id="registrarse">
                <h1>Empresa</h1>
                <form action="Guardarregistro2.php" method="post">
                    <input type="text" style="visibility:hidden" value="empresa">
                    <div class="fila-arriba">
                        <div class="contenedor-input">
                            <label>
                                Usuario <span class="req">*</span>
                            </label>
                            <input type="text" pattern="[A-Za-z0-9.]{1,20}" name="usu" required >
                        </div>

                        <div class="contenedor-input">
                            <label>
                                Contraseña <span class="req">*</span>
                            </label>
                            <input type="text" pattern="[A-Za-z0-9.]{1,20}" name="contra" required>
                        </div>
                    </div>
                    <div class="contenedor-input">
                        <label>
                            Razón Social <span class="req">*</span>
                        </label>
                        <input type="text" pattern="[A-Za-z0-9.]{1,60}" name="rs" required>
                    </div>
                    <div class="contenedor-input">
                            <label>
                                Ruc <span class="req">*</span>
                            </label>
                        <input type="text" pattern="[0-9.]{1,11}" name="ruc" required>
                    </div>
                    <div class="contenedor-input">
                        <label>
                            Correo <span class="req">*</span>
                        </label>
                        <input type="email" name="cor" required>
                    </div>

                    <div class="contenedor-input">
                        <label>
                            Telefono <span class="req">*</span>
                        </label>
                        <input type="text" pattern="[0-9.]{7}" name="tel" required>
                    </div>
                      <div class="contenedor-input">
                        <label>
                            Direccion <span class="req">*</span>
                        </label>
                        <input type="text"  name="dir" required>
                    </div>
                                        <br>
                    <p class="forgot"><a href="index.php">Tienes Cuenta ? Login </a></p>
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