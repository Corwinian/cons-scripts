echo "every day cons update"

$cons_path="C:\Consultant\"

$cons_et_path = "Cons_Reg\"
$cons_prim_path = "Cons_Prim\"
$cons_buh_path = "Buh\"
$cons_ros_path = "Ros\"

$quest_dir="C:\For_Cons\quests\" 
$update_dir="C:\For_Cons\пополнение\" 

$comare_dir="Z:\COMMON\" 

#(Get-Date).DayOfWeek() 

$quest_date = Get-Date ((Get-Date).AddDays(-1)) -f "MM_dd_yy"	
	
function create_quests($arg){
	$cons_type = $arg
	echo ("cons type - " + $cons_type)
	
	echo ("date - " + $quest_date)

	echo "create quests"
	start -wait ($cons_path + $cons_type + "cons.exe ") -argumentList ("/adm /quest /BASE* /yes")

	#убиваем фиктивный запрос по law если приморский выпуск
	if ($cons_type -eq $cons_prim_path ){
		rm ($cons_path + $cons_type + "send\law*")
	}
	
	echo "move quests"
	$send_dir = $quest_dir + $cons_type + $quest_date
	echo ("send dir"+$send_dir)
	
	mkdir $send_dir
	mv ($cons_path + $cons_type + "send\*") $send_dir
}
	
	
function update_base ($arg){
	$cons_type = $arg[0]
	$bases = $arg[1]
	$inet_res = $arg[2]

	echo "create BASELIST"
	echo $bases | out-file -encoding ascii ($cons_path + $cons_type +"/base/BASELIST.CFG")

	create_quests($cons_type)
	
	echo "update cons"
	start -wait ($cons_path + $cons_type + "cons.exe ") -argumentList ("/adm " + $inet_res + " /receive_inet /yes /base*")

	echo "remove BASELIST"
	rm ($cons_path + $cons_type + "/base/BASELIST.CFG")
	echo "update dicts"
	start -wait ($cons_path + $cons_type + "cons.exe ") -argumentList ("/adm /reindex0")
}

echo "save quest buh"
create_quests($cons_buh_path)
echo "save quest ros"
create_quests($cons_ros_path)
echo "---------------------------------------------------------------------------"
echo "- эталоны                                                                  "
echo "---------------------------------------------------------------------------"

#$needed_bases = @("law" );
$needed_bases = @(
	"adv", "arb", 	"cji", "cmb", "exp", "int", "kor", "krbo", "law", "marb", "med", "pap", 
	"pbi", "pbun", "pdr", "pgu", "pkbo", "pkp", "pks", "pkv", "ppn", "pps", "psp", "psr"
	"qsbo", "quest", "scn", "sdv", "sms", "soj", "spb", "spv",	"ssk", "ssz", "str", "sur", "svs", "svv", "szs",
	"rlaw011", "rlaw080", "rlaw210", "rlaw284", 	"rlaw439")

update_base $cons_et_path, $needed_bases, "/inet_host";

echo "end reg update"

echo "---------------------------------------------------------------------------"
echo "- Приморский                                                             --"
echo "---------------------------------------------------------------------------"

echo "create prim"
$prim_needed_bases = @("law", "raps005", "raps006", "rarb020", "rbas020", "rlaw020")  #law добавлденн из_за того что без него не создаються запросы

update_base $cons_prim_path, $prim_needed_bases, "/inet_ext";

echo "---------------------------------------------------------------------------"
echo "- create et and prim update                                                "
echo "---------------------------------------------------------------------------"

$shift_days = $args[0]

$start_date = Get-Date ((Get-Date).AddDays($shift_days)) -f "MM_dd_yy"
$update_date = Get-Date ((Get-Date).AddDays($args[1])) -f "MM_dd_yy"

echo "create update dir"
mkdir ($update_dir+$update_date)

echo ("quest dir - " + $start_date)
echo ("update dir dir - " + $update_date)

function create_update ($arg){
	$cons_types = $arg[0]
	$cons_path = $arg[1]
	echo "copy cons quests"
	foreach($cons in $cons_types){
		cp ($quest_dir + $cons + $start_date + "\*") ($cons_path + "receive/" )
	}
	
	echo "creare cons answers"
	start -wait ($cons_path + "cons.exe ") -argumentList ("/adm /answer /Base*")
	mv ($cons_path + "send\*") ($update_dir+$update_date+"\")
}

echo "create update for cons buh ros"
create_update(@($cons_et_path, $cons_buh_path, $cons_ros_path), ($cons_path + $cons_et_path) )

echo "create update for prim"
create_update(@($cons_prim_path), ($cons_path + $cons_prim_path))

#if ($shift_days -eq -1){
#	rm -Recurse $update_dir+$update_date
#}

function update_cons ($cons_type){
	
	echo "- copy update files"
	cp ($update_dir+$update_date + "\*") ($cons_path + $cons_type + "receive/")
	echo "- udate cons"
	start -wait ($cons_path + $cons_type + "cons.exe ") -argumentList ("/adm /receive /Base*")
	echo "- end udate"
}

echo "---------------------------------------------------------------------------"
echo "- update local bases                                                       "
echo "---------------------------------------------------------------------------"

echo "- update prim bases"
update_cons ($cons_prim_path)

echo "- update ros bases"
update_cons ($cons_ros_path)

echo "- update buh bases"
update_cons ($cons_buh_path)
echo "- end update"
