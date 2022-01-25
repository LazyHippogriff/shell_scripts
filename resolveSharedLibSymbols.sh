[root@mu99dc201upfxoc1j sharedLibTest]# cat resolveSharedLibSymbols.sh
#!/bin/bash

if [ "$#" -ne 1 ]
then
    echo "1 argument needed in the script"
    echo "e.g. $0 [binary name(complete path)]"
    exit
fi

if [ -f $1 ]
then
    echo "Going to find the unresolved symbols found in \"$1\""
else
    echo "Binary file \"$1\" not found. Check name/path."
fi

binaryFile=$1

lddOutput=`ldd $binaryFile | awk '{print $3}' | grep -v "0x" | awk 'NF >0'`

#echo "$lddOutput"

sharedDependencies=()

for lib in `readelf -d $binaryFile | grep -i "Shared library" | awk '{print $5}' | sed -e 's/\[//g' | sed -e 's/\]//g'`;
do
sharedDependencies+=(`grep $lib lddOutput`)
done

rm -f allSymbols.temp
rm -f result.txt

# Iterate the loop to read and print each array element
echo -e "\nGiven below are the dependencies found for $binaryFile\n"
for lib in "${sharedDependencies[@]}"
do
echo $lib
#Create list of all text symbols from all the libraries
#for symbol in `nm -gD $lib | awk '{$1=""}1' | grep " T \| W \| V \| w \| v \| t " | awk '{print $2}'`;
#for symbol in `nm -gD $lib | grep -i " T \| W \| V "`;
nm -gD $lib | grep -i " T \| W \| V \| I " | while read symbol;
do
string=
sym=
#echo -e "\nsymbol->$symbol" >> debug.txt
n=`echo $symbol | awk "{print NF}"`
#echo -e "n->$n\n" >> debug.txt
if [ $n -eq 2 ]
then
sym=`echo $symbol | awk '{print $2}'`
else
sym=`echo $symbol | awk '{print $3}'`
fi

string="$lib contains $sym"
echo $string >> allSymbols.temp
#echo $string >> debug.txt
done
done

undefinedDynamicSymbols=`nm -uD $binaryFile | awk '{print $2}'`
#echo -e "\n\nUndefinedDynamicSymbols\n$undefinedDynamicSymbols\n"

for undefinedSymbol in $undefinedDynamicSymbols;
do
echo $undefinedSymbol >> result.txt
grep  -w $undefinedSymbol allSymbols.temp >> result.txt
echo -e "\n" >> result.txt
done

rm -f allSymbols.temp
[root@mu99dc201upfxoc1j sharedLibTest]#
