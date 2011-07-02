# ORM generator for Zend FramewoC:\pl-dev\orm-gen-0.2.plrk
# Generates ZF ORM file structure from MySQL Workbench SQL export script
# Author: zavg
# Version: 0.1
# Date: 02.07.2011


# Zend_DB_Table class creation procedure
sub dbtable
{
	$name = lcfirst $_[0];
	$Name = ucfirst $_[0];	
	open (DB_TABLE_TPL, "<templates/dbtable.tpl") || die("DBTable template file does not found");
	open (DB_TABLE_OUT, ">".@ARGV[1]."DBTable/".$Name.".php") || die("DBTable php-source file creation failed");
	print @ARGV[1]."DBTable/".$name.".php created\n";
	while(<DB_TABLE_TPL>)
	{
		s/{name}/$name/;
		s/{Name}/$Name/;
		s/{id}/$id/;
		print DB_TABLE_OUT;
	}
	close DB_TABLE_TPL;
	close DB_TABLE_OUT;
}

# Data mapper class creation procedure
sub mapper
{
	$name = ucfirst $_[0];
	print @ARGV[1].$name."Mapper.php created\n";
	open (MAPPER_TPL, "<templates/mapper.tpl") || die("Data mapper template file does not found");
	open (MAPPER_OUT, ">".@ARGV[1].$name."Mapper.php") || die("Data mapper php-source file creation failed");
	$name = lcfirst $name;
	$Name = ucfirst $name;
	$Id = ucfirst $id;
	while(<MAPPER_TPL>)
	{
		s/{name}/$name/g;
		s/{Name}/$Name/g;
		s/{id}/$id/g;
		s/{Id}/$Id/g;
		if(/{data}/)
		{
			print MAPPER_OUT "\t\$data = array(\n";
			foreach $var (@vars)
			{
				$Var = ucfirst $var;
				print MAPPER_OUT "\t\t\'$var\' => \$$name->get$Var(),\n"
			}
			print MAPPER_OUT "\t\);\n";
			next;
		}
		if(/{(\w+)_set}/)
		{
			if(/{name_set}/)  { print MAPPER_OUT "\t\$$name"; }
		        if(/{entry_set}/) { print MAPPER_OUT "\t\$entry"; }
			$bFirstVariable = 1;
			foreach $var (@vars)
			{
				$Var = ucfirst $var;
				if($bFirstVariable)
				{
					print MAPPER_OUT "->set$Var\(\$row->$var\)";
				 	$bFirstVariable = 0;
				}
				else
				{
					print MAPPER_OUT "\n\t\t->set$Var\(\$row->$var\)";
				}
			}
			print MAPPER_OUT ";\n";
			next;
		}

		print MAPPER_OUT;
	}
	close MAPPER_TPL;
	close MAPPER_OUT;
}

# Data model class creation procedure
sub model
{
	$name = lcfirst $_[0];
	$Name = ucfirst $_[0];
	print @ARGV[1].$Name.".php created\n";
	open (MODEL_TPL, "<templates/model_class.tpl") || die("Data model template file does not found");
	open (MODEL_OUT, ">".@ARGV[1].$Name.".php") || die("Data model php-source file creation failed");
	open (COMMON_MODEL_TPL, "<templates/common_model.tpl") || die("Template file for coomon model functions does not found");
	@common = ();
	while(<COMMON_MODEL_TPL>)
	{
		push @common, $_;
	}
	close COMMON_MODEL_TPL;
	while(<MODEL_TPL>)
	{
		s/{name}/$name/;
		s/{Name}/$Name/;
		s/{vars}/@php_vars/;
		s/{common}/@common/;
		if(/{set_get}/)
		{
		foreach $var (@vars)
		{
			$Var = ucfirst $var;
			$var = lcfirst $var;
			open (SETTER_TPL, "<templates/setter.tpl") || die("Setter template file does not found");
			while(<SETTER_TPL>)
			{
                        	s/{Var}/$Var/g;
				s/{var}/$var/g;
				print MODEL_OUT;
			}
			close SETTER_TPL;

			open (GETTER_TPL, "<templates/getter.tpl") || die("Getter template file does not found");
			while(<GETTER_TPL>)
			{
				s/{Var}/$Var/g;
				s/{var}/$var/g;
				print MODEL_OUT;
			}
			close GETTER_TPL;
		}
		}
		else
		{
			print MODEL_OUT;
		}
	}
	close MODEL_TPL;
	close MODEL_OUT;
}

# Command line arguments reading 
# @ARGV[0] - path to SQL-script file for parsing
# @ARGV[1] - path to folder for generated files to be placed into

open (IN, @ARGV[0]) || die("Input SQL-script file does not specified");
if(!(@ARGV[1] eq ''))
{
	# New folders creation if does not exists
	(-d @ARGV[1]) || mkdir @ARGV[1];	
	(-d @ARGV[1]."/DBTable") || mkdir @ARGV[1]."/DBTable";
	print "\nModel objects creation in @ARGV[1]:\n";
	@ARGV[1] .= "/";		
}
else
{
	# New folder creation if does not exists
	(-d @ARGV[1]."DBTable") || mkdir @ARGV[1]."DBTable";
}


# Main routine: SQL parsing and PHP ORM files generating

while(<IN>)
{        
	# Identifing the beginning of the SQL-table description
	if(/(?<=CREATE TABLE IF NOT EXISTS `)(\w+)/)
	{
		$name = $+;
		$str = $_;
		$id = "";
		@php_vars = ();
		@vars = ();
		# Identifing the end of the SQL-table description
		while(!($str =~ /^\)/))
		{

			$str = <IN>;
			# Reading table fields
			if($str =~ /(?<=  `)(\w+)/)
			{
				push @php_vars, "\tprotected \$_".(lcfirst $+).";\n";
				push @vars, $+;
			}
			# Reading primary key
			if($str =~ /(?<=  PRIMARY KEY \(`)(\w+)/)
			{
				$id = $+;
			}			
		}
		dbtable $name;
		mapper $name;
		model $name;
	}
}
close IN;