<!DOCTYPE html>
<?php
  function print_attrs($attributeArray )  {
	$nok_flag=0;

  foreach ($attributeArray  as $attribute => $options) {
    $print = TRUE;
    $state = STATE_EMPTY;
	$class_decode='active';


    switch($options[0]) {
      case NONEED:	$print= TRUE;
      			break;
      
      case OPTIONAL:    if(! empty ($_SERVER[$attribute]) ) {
			  $state = STATE_OK;
      			} else {
			  $state = STATE_OPTIONAL;
			}
      			break; 
      
      case REQUIRED:    if(! empty ($_SERVER[$attribute]) ) {
			  if(! empty( $options[1] )) {
			    $values = explode(";", $_SERVER[$attribute]);
			    $state = STATE_NOK; 
			    foreach ( $values as $value ) {
				    if (preg_match('/'.$options[1].'/i', $value)) { 
				      $state = STATE_OK;
				    } 
			    }
			    if ($state == STATE_NOK) $nok_counter++;
			    
			  } else {
			    $state = STATE_OK;
			  }	
			} else {
      			  $state = STATE_EMPTY;
			  $nok_flag=1;
			}
			break;
      			
    }
if ($state==STATE_NOK) 		$class_decode='danger';
if ($state==STATE_OK) 		$class_decode='success';
if ($state==STATE_OPTIONAL) $class_decode='warning';
if ($state==STATE_EMPTY) 	$class_decode='danger';
if ($options[0]==NONEED) 	$class_decode='info';
if (($state==STATE_OK)and ($options[0]== REQUIRED)) 		$class_decode='active';


    if ($print) {
	    echo "\n\t".'<tr class="'.$class_decode.'">';
	    echo "\n\t\t".'<td><img src="'.$state.'" alt="'.$state.'"/></td>';
	    echo "\n\t\t".'<td><samp>'.$options[0].'</samp></td>';
	    echo "\n\t\t".'<td><samp>'.$options[1].'</samp></td>';
	    echo "\n\t\t".'<td><samp>'.$options[2].'</samp></td>';
	    echo "\n\t\t".'<td><samp>'.$attribute.'</samp></td>';
	    if ( isset ($_SERVER[$attribute]) ) { 
		    echo "\n\t\t".'<td><samp>'.str_replace(";","<br />\n", $_SERVER[$attribute]).'</samp></td>';
            } else {
		    echo "\n\t\t".'<td><samp>&nbsp;</samp></td>';
            }
	    
	    echo "\n\t".'</tr>';
    }
   }  
  return $nok_flag;
  }
define ("NONEED", "Not needed");
define ("OPTIONAL", "Optional");
define ("REQUIRED", "Required");

####START CONFIGURATION####

//Fill in the name of the application
$name = 'Test Service Provider';
//List of attributes that will be checked.

require('attributes_map.php');
	
?>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../../favicon.ico">

    <title>Narrow Jumbotron Template for Bootstrap</title>

    <!-- Bootstrap core CSS -->
    <link href="/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="narrow-jumbotron.css" rel="stylesheet">
  </head>

  <body>

    <div class="container">
	
      <div class="header clearfix">
 <!--       <nav>
          <ul class="nav nav-pills pull-xs-right">
            <li class="nav-item active">
              <a class="nav-link" href="#">Home <span class="sr-only">(current)</span></a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">About</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">Contact</a>
            </li>
          </ul>
        </nav>
-->
        <h2 class="text-muted text-center"">Diagnostica Service Provider</h2>
      </div>

      <div class="jumbotron">
        <h3 class="text-center">Informazioni di sessione</h3>
 <table class="table table-bordered table-hover table-condensed">
    <thead>
      <tr>
        <th>Variabile</th>
        <th>Valore</th>
       </tr>
    </thead>

<tr class="info">
	<td > <span style="font-style:italic;"><samp> REMOTE_USER </samp></span></td>
	<td ><span style="font-style:italic;"><samp> <?php if (isset($_SERVER['REMOTE_USER'])) echo $_SERVER['REMOTE_USER'] ?></samp></span></td>
</tr>
<?php 
//

 	foreach ($_SERVER as $attribute => $valore) {
 	  if ( (preg_match('/shib/i', $attribute))) { 
                echo "<tr> ";
                echo "<td ><span style=\"font-style:italic;\"><samp>".$attribute."</samp></span></td>";
                // values are sent UTF8, must decode to ISO
                echo "<td><span style=\"color: gray; font-style:italic;\"><tt>".wordwrap($valore, 80, "<br />\n", true)."</tt></span></td>";
                echo "</tr>";
        }
	}

?>
</table>

     </div>
	 
<div class="container">
  <h2 class="text-center">Check attributi</h2>
  <p>Verifica degli attributi disponibili alla applicazione finale</p>
 <table class="table table-bordered table-hover table-condensed">
     <tr>
        <th>Staus</th>
        <th>Requirement</th>
        <th>Required value</th>
        <th>SAML2 attribute name</th>
		<th>Environment Variable</th>
		<th>Value</th>
		</tr>
    </thead>
    <tbody>
	  <?php
  define ("STATE_EMPTY", "images/empty.png");
  define ("STATE_NOK", "images/nok.png");
  define ("STATE_OK", "images/ok.png");
  define ("STATE_OPTIONAL", "images/optional.png");
  
  $nok_counter = 0;
  $header_name = "Environment Variable"; 
 
   
$flag_required=1;    
$flag_optional=1;
$flag_noneed=1;
   
    if (($flag_required==1)){    
  	//prima quelli presenti in $_SERVER
  	$nok_counter = $nok_counter + print_attrs(array_intersect_key($attributes_required, $_SERVER));
  	//poi quelli NON presenti in $_SERVER
  	$nok_counter = $nok_counter + print_attrs(array_diff_key($attributes_required, $_SERVER));
  	}
    if (($flag_optional==1)){    
  	//prima quelli presenti in $_SERVER
  	$nok_counter = $nok_counter + print_attrs(array_intersect_key($attributes_optional, $_SERVER));
  	//poi quelli NON presenti in $_SERVER
   	$nok_counter = $nok_counter + print_attrs(array_diff_key($attributes_optional, $_SERVER));
 	}
    if (($flag_noneed==1)){    
  	//prima quelli presenti in $_SERVER
  	$nok_counter = $nok_counter + print_attrs(array_intersect_key($attributes_noneed, $_SERVER));
  	//poi quelli NON presenti in $_SERVER
  	$nok_counter = $nok_counter + print_attrs(array_diff_key($attributes_noneed, $_SERVER));
  	}
 ?>   
  
    </tbody>
  </table>
</div>


<div class="row marketing">
 
</div>
	  
	  <?php
if (isset($_GET['all_variables'])) {
    echo '<div class="jumbotron">';
	echo' <h4 class="text-center">Variabile $_SERVER</h4>';
	echo' <table class= "table table-bordered table-hover table-condensed" >';
    echo '<tr><td>Variabili Web server </td><td>Valori</td></tr>';
    ksort($_SERVER);
    foreach ($_SERVER as $key => $value) {
        echo '<tr>';
        echo "<td><tt>$key</tt></td>";
        if (!is_array($value)){
            $value =  str_replace(";","<br>\n", $value);
			$value =  wordwrap($value, 80, "<br>\n" ,true);
        }
        echo "<td ><tt>$value</tt></td>";
        echo "</tr>";
    }
    echo '</table></div>';
}

if (isset($_REQUEST['source'])) {
	highlight_file(__FILE__);
//        exit;
}

?>
	  
	  

      <footer class="footer">
        <p>&copy; Idem  2016 &nbsp; &nbsp;<a href="?all_variables">Visualizza variabile $_SERVER</a>&nbsp; &nbsp;<a href="?source">Visualizza il codice sorgente</a></p>
      </footer>

    </div> <!-- /container -->


    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="../../assets/js/ie10-viewport-bug-workaround.js"></script>
	</body>
</html>
