<?php
//define(SERVER, "http://95.154.250.249:4567/careers");

$visualizationType = $_GET["v"];

$response = "";
$jsonfile = "";
switch($visualizationType) {
	case "tagcumulus":
		$jsonfile = "./json/tagsCumulusJSON_mini.json";
		break;
	case "tagcumulusfull":
		$jsonfile = "./json/tagsCumulusJSON_full.json";
		break;	
	case "tagcloud":
		$jsonfile = "./json/tagsCloudJSON_mini.json";
		break;
	default:
	case "remotevslocal":
		$jsonfile = "./json/remoteVSlocal.json";
	break;
	case "tagsgraph":
		$jsonfile = "./json/tagsGraph.json";
	break;
	default:
	break;	
}

$response = file_get_contents($jsonfile);

print htmlspecialchars($response, ENT_NOQUOTES)
?>