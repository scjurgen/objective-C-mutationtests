<?php
/*
project file
ASMutLocalSunRiseTest_Mutated.m

cd ../testMutationsTDDMutants
xcodebuild test -scheme testMutationsTDD -destination "name=iPhone Retina (4-inch)"

*/

//echo $argv[1]."\n";

$settingsFile = file_get_contents($argv[1]) or die('Configuration load error!

Please provide a valid json configuration file; something like:

{
	"originalpath":"./testMutationsTDD",
	"mutantcopypath":"./testMutationsTDDMutants",
	"project":"testMutationsTDD.xcodeproj"
}

');

$settings = json_decode($settingsFile);

//print_r($settings);
@mkdir($settings->mutantcopypath);
$cpStuff="cp -fR ".$settings->originalpath."/* ".$settings->mutantcopypath;
echo $cpStuff;
system ($cpStuff);
require("mutate.php");

function parseGroupWithChildren($curPath,$id,&$project,&$filelist, $pass=0)
{
	if ($pass==0)
	{
		$p = "/{$id}([^{=]*)= {[^{]*path = ([^;]*)UnitTests.m; sourceTree = \"<group>\"/siU";
		if (preg_match($p,$project,$m))
		{
			$filelist[$m[2].".m"] = $curPath.$m[2]."UnitTests.m";
//			echo $curPath.$m[2]."\n";
			return;
		}
	}
	else
	{
		foreach($filelist as $key => $value)
		{
			$p = "/{$id}([^{=]*)= {[^{]*path = ({$key}); sourceTree = \"<group>\"/siU";
			if (preg_match($p,$project,$m))
			{
				$filelist[$key] = $curPath.$m[2]."";
	//			echo $curPath.$m[2]."\n";
				return;
			}
			
		}		
	}	
	if (preg_match("/{$id}([^{=]*)= {[^}]*children = \\(([^}]*)\\)[^}]*}/siU",$project,$m))
	{
		//echo $m[1]."\n";
		if (preg_match('/path = ([a-z0-9]+);/siU',$m[0],$pathname))
		{
			$curPath .= $pathname[1]."/";
			//echo "cp={$curPath}\n";
		}
		if (preg_match_all('/([0-9a-f]{24})/iU',$m[2],$children))
		{
			for ($i=0; $i < count($children[1]); $i++)
			{
				//echo ">".$children[1][$i]."\n";
				parseGroupWithChildren($curPath,$children[1][$i],$project,$filelist,$pass);
			}	
		}
		else
		{
			die("no entry found with an id");
		}
	}
}


function removeComments($infile)
{
	$infile = preg_replace("#\\s*//[^\n]*\n#sU","\n",$infile);
	$infile = preg_replace("#/\\*.*\\*/#sU"," ",$infile);
	return $infile;
}

$projectPath = $settings->originalpath."/".$settings->project."/project.pbxproj";
//echo $projectPath."\n";

$project = file_get_contents($projectPath) or die("Fatal Error: Can't open project '$projectPath'\nParsing aborted!\n");
$filelist = array();

if (preg_match('/mainGroup = ([0-9a-f]+);/iU',$project,$m))
{
	parseGroupWithChildren("/",$m[1], $project,$filelist,0);
	//print_r($filelist);
	parseGroupWithChildren("/",$m[1], $project,$filelist,1);
	//print_r($filelist);
	foreach($filelist as $localFile => $fileWithPath)
	{
		$sourceFile = $settings->originalpath."/".$fileWithPath;
		$sourceCode = file_get_contents($sourceFile ) or die("Can't open sourcefile: ".$sourceFile );
		$sourceCode = removeComments($sourceCode);
		$o = new mutateSource($sourceCode);
		$o->findMutableGenes();
		for($i = -1; $i < count($o->mutants); $i++)
		{
			$mutantCode = $o->createMutant($i);
			$targetFile = $settings->mutantcopypath."/".$fileWithPath;
			file_put_contents($targetFile, $mutantCode) or die("Can't create mutantsourcefile: ".$targetFile);
			
			$workdir = getcwd();
			chdir($settings->mutantcopypath);
			$cmd = "xcodebuild test -scheme testMutationsTDD -destination \"name=iPhone Retina (4-inch)\" 2>&1";
			$returnValue = array();
			exec($cmd, $returnValue);
			chdir($workdir);
			$result = implode($returnValue);
			$matchResult = array();
			if (preg_match("/\\*\\*\\s+TEST ([A-Z]*)\\s+/",$result,$matchResult))
			{
				if($matchResult[1] == "SUCCEEDED")
				{
					if ($i==-1)
					{
						echo " Unit test OK\n";
					}
					else
					{
						echo " Warning: NOT KILLED!\n";
					}
				}
				if($matchResult[1] == "FAILED")
				{
					if ($i==-1)
					{
						echo "Unit test NOT OK\nFix this first before creating mutants\n\n";
						exit;
					}
					else
					{
						echo " killed successfully!\n";
					}				
				}
			}
			
			//echo $returnValue;
			
			//exit;
		}
	}
}
else
{
	die ("maingroup not found in project");
}


?>