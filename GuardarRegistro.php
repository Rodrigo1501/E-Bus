<?php
session_start();
include('conectar.php');


$a = $_POST['usu'];
$b = $_POST['contra'];
$c = $_POST['nom'];
$d = $_POST['ape'];
$e = $_POST['cor'];
$f = $_POST['dni'];
$g = $_POST['tel'];
$h = $_POST['dir'];

$ssql = "SELECT * FROM cliente WHERE usu_cli='$a' or cor_cli='$e' or dni_cli='$f' or tel_cli='$g' "; 
$rs = $db->prepare($ssql);
$rs->execute();
$p=$rs->rowCount();

$ssqll = "SELECT * FROM empresa WHERE usu_emp='$a' or tel_emp='$g' "; 
$rss = $db->prepare($ssqll);
$rss->execute();
$pp=$rss->rowCount();

if ($p!=0 || $pp!=0){ 
   	//usuario encontrado

       echo "Algunos Campos coinciden con otros Usuarios ";	
}
else { 
  
   

//query
$sql = "INSERT INTO cliente (usu_cli,pass_cli,nom_cli,ape_cli,cor_cli,dni_cli,tel_cli,dir_cli) VALUES (:a,:b,:c,:d,:e,:f,:g,:h)";
$q = $db->prepare($sql);
$q->execute(array(':a'=>$a,':b'=>$b,':c'=>$c,':d'=>$d,':e'=>$e,':f'=>$f,':g'=>$g,':h'=>$h)) or die (mysql_error());
        $uidcheck=$q->rowCount();
        if ($uidcheck!=0){
            echo "Guardado";
        }

}


?>