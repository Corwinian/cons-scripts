$spec_path = "C:\For_Cons\spec\" 

$partner_path="партнеры\"
$commar_path="commar\"
$serves_path="сервесные\"

$cons_path="C:\Consultant\"
$cons_et_path="Cons_Reg\"
$cons_prim_path="Cons_Prim\"
$quest_dir="C:\For_Cons\quests\" 

function create_special($arg){
	$res_folder = $arg
	$ext_folder = $arg

	echo ("res_folder" + $res_folder)
	echo ("ext_folder" + $ext_folder)
	
	$rlaw_bases = @("raps005", "raps006", "rlaw020", "rbas020", "rarb020")
	
	$move_list = [system.collections.arraylist]@()

	foreach ($base in $rlaw_bases){
		$move_list.add($res_folder +"\"+ $base +"*.qst")
	}

	echo ("move lsit" + $move_list)
	echo ("prim bases")
	if ((ls -path ($move_list)) -ne $null){
		echo "creating"
		echo ("move list" + $move_list)
		ls -path $move_list | mv -destination ($cons_path + $cons_prim_path + "\receive\")
		start -wait ($cons_path + $cons_prim_path + "cons.exe ") -argumentList ("/answer /BASE*")
		mv ($cons_path + $cons_prim_path + "send/*")  $ext_folder
	}
	else {
		echo "no bases"
	}
	
	echo ("et bases")
	if ((ls -path ($res_folder + "\*.qst")) -ne $null){
		echo "creating"
		echo ("et bases")
		ls -path ($res_folder + "\*.qst") | mv -destination ($cons_path + $cons_et_path + "\receive\" )
		start -wait ($cons_path + $cons_et_path + "cons.exe ") -argumentList ("/answer /BASE*")
		mv ($cons_path + $cons_et_path + "send/*")  $ext_folder
	}
	else {
		echo "no bases"
	}
}

function create_by_orgs($path){
	echo "make serves for commar"
	foreach($dir in  ls ($path)){
		$dir_name = $path + "\" + $dir.name
		echo ( "sp dir" + $dir_name)
		create_special($dir_name)
	}
}

function create_by_users($path){
	echo "make serves for commar"
	foreach ($spec in ls ($path)){
		create_by_orgs($path + $spec.name)
	}
}

echo "make spec for commar"
create_by_orgs($spec_path + $commar_path)

echo "make spec for serves"
create_by_users($spec_path + $serves_path)

echo "make spec for partner"
#create_by_users($spec_path + $partner_path)
create_by_orgs($spec_path + $partner_path)