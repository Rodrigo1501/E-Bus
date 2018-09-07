<?php
session_start();
include('conectar.php');


$a = $_POST['usu'];
$b = $_POST['contra'];
$c = $_POST['rs'];
$d = $_POST['ruc'];
$e = $_POST['cor'];
$f = $_POST['tel'];
$g = $_POST['dir'];

$ssql = "SELECT * FROM empresa WHERE usu_emp='$a' or ruc_emp='$d' or cor_emp='$e' or tel_emp='$f' "; 
$rs = $db->prepare($ssql);
$rs->execute();
$p=$rs->rowCount();

$ssqll = "SELECT * FROM cliente WHERE usu_cli='$a' or tel_cli='$f' "; 
$rss = $db->prepare($ssqll);
$rss->execute();
$pp=$rss->rowCount();

if ($p!=0 ||$pp!=0 ){ 
   	//usuario encontrado

       echo "Algunos Campos coinciden con otros Usuarios";	
}
else { 

//query
$sql = "INSERT INTO empresa (usu_emp,pass_emp,raz_soc_emp,ruc_emp,cor_emp,tel_emp,dir_emp) VALUES (:a,:b,:c,:d,:e,:f,:g)";
$q = $db->prepare($sql);
$q->execute(array(':a'=>$a,':b'=>$b,':c'=>$c,':d'=>$d,':e'=>$e,':f'=>$f,':g'=>$g)) or die (mysql_error());
        $uidcheck=$q->rowCount();
        if ($uidcheck!=0){
            echo "Guardado";
        }

}


?>