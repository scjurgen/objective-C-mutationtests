<?php
/*
*/

/*if (isset($argv[1]))
{	
	$sourceCode = file_get_contents($argv[1]) or die("Can't open sourcefile: ".$argv[1]);
	
	$o = new mutateSource($sourceCode);
	$o->findMutableGenes();
	
}
*/

class mutateSource
{
	private $md5;
	private $sourceCode;
	public $mutants;

	function __construct($sourceCode) 
	{
		$this->sourceCode = $sourceCode;
		$this->md5 = md5($sourceCode);
		// if source code did not change don't analyse again and do nothing (or show saved results)
		$mutants = array();
    }
    
    function findExpressionMutant($operator,$substitute)
    {
    	$varNum = '\s*[a-zA-Z0-9.]+\s*';
    	$regex = '#('.$varNum.preg_quote($operator).$varNum.')#siU';
    	if (preg_match_all($regex,$this->sourceCode, $match, PREG_OFFSET_CAPTURE))
    	{
    		for ($i=0; $i < count($match[0]);$i++)
    		{
    			$this->mutants[] = array("type" => "expression", "count" => $i, "operator" => $operator, "substitute" => $substitute, "position" => $match[0][$i][1]);
	    	}
    	}
    }
    
    
    function ternaryMutant()
    {
    	$regex = '#\?([^:]+):([^:]+)\)?;#siU'; //, '$2:$1'
    	if (preg_match_all($regex,$this->sourceCode, $match, PREG_OFFSET_CAPTURE))
    	{
    		for ($i=0; $i < count($match[0]); $i++)
    		{
    			$this->mutants[] = array("type" => "ternary", "count" => $i, "operator" => $regex, "substitute" => "$2:$1", "position" => $match[0][$i][1]);
	    	}
    	}
    }

	function findMutableGenes()
	{
		$expr = array(
			'+' => '-', // only if second operand != 0
			'-' => '+', // only if second operand != 0
			'*' => '/', // only if second operand != 1
			'/' => '*', // only if second operand != 1
			'%' => '/', // only if second operand over range of modulo
			'>=' => '<',
			'>'  => '<=',
			'<=' => '>',
			'<'  => '>=',
			'==' => '!=',
			'&&' => '||', // only if both operands != 0
			'||' => '&&', // only if both operands != 0
			'&=' => '|=',
			'|=' => '&=',
			'^=' => '^=^',// only if second operand != 0
			'+=' => '-=',// only if second operand != 0
			'-=' => '+=',
			'*=' => '/=',// only if second operand != 1
			'/=' => '*=',// only if second operand != 1
			'--' => '++',
			'++' => '--',
			'=!' => '=!!',
			'= !' => '= !!',
			);
		foreach($expr as $original => $substitute)
		{
			$this->findExpressionMutant($original,$substitute);
		}
		//$this->ternaryMutant();
		echo "Possible mutants found: ".count($this->mutants)."\n";
	}

	public function createMutant($nr)
	{
		if ($nr == -1)
		{
			return $this->sourceCode;
		}
		//print_r($this->mutants[$nr]);
		$item = $this->mutants[$nr];
		$varNum = '\s*[a-zA-Z0-9.]+\s*';
    	$regex = '#('.$varNum.")(".preg_quote($item["operator"]).")(".$varNum.')#siU';
		$substituteExpression = '$1'.$item["substitute"].'$3';
		echo "Mutant {$nr}:p=".$item["position"].":s=".$item["substitute"]." >";
		$head = substr($this->sourceCode,0,$item["position"]);
		$tail = substr($this->sourceCode,$item["position"]);

		$mutantSourceCode = $head.preg_replace($regex,$substituteExpression, $tail, 1);
		//echo $mutantSourceCode;
		return $mutantSourceCode;
	}
}

?>