roundUp() {

# Call common function to execute common function start commands, such as setting verbose output etc
functionStart

# Necessary as Vagrantfile was rounding up .5, unlike awk which is rounding that down
number=$1

bc << EOF
num = $number;
base = num / 1;
if (((num - base) * 10) >= 5 )
    base += 1;
print base;
EOF
echo ""

# Call common function to execute common function start commands, such as unsetting verbose output etc
functionEnd

}
