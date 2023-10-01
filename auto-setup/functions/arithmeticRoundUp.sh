####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
roundUp() {

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

}
