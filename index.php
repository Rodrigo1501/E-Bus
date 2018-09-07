<!DOCTYPE html>
<html lang="es">
<head>
	<title>LogIn</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
	<link rel="stylesheet" href="css/mainn.css">
</head>
<body class="cover" style="background-image: url(./assets/loginFont.jpg);">
<div class="error">
<span> Datos de ingreso no validos, intentelo nuevamente por favor </span>
</div>
<div class="main">
<form action="" id="formlg">
<div> <img src="./assets/perfil.png"</div>
</br>
</br>
<input type="text" name="usuariolg" placeholder="Usuario" required />
<input type="password" name="passlg" placeholder="Contraseña" required />
<input type="submit" name="botonlg" onclick = "funcion();" value="Iniciar Sesion" />
</form>
</div>
	<!--====== Scripts -->
<script src="js/jquery-3.1.1.min.js"></script>
	<script>
		$.material.init();
	</script>
</body>
</html>