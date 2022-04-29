#!/bin/bash
echo ""
echo "Downloading three prostate sample cases from the internet..."
echo ""

mkdir sampledata
cd sampledata

mkdir case_1
cd case_1
declare -a arr=(
"https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0001-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0002-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0003-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0004-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0005-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0006-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0007-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0008-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0009-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0010-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0011-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0012-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0013-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0014-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0015-0001-199.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0016-0001-198.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0017-0001-198.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0018-0001-198.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0019-0001-198.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0020-0001-198.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0021-0001-197.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0022-0001-197.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0023-0001-196.dcm" "https://web.archive.org/web/20200108043437/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0024-0001-196.dcm"
)
for i in "${arr[@]}"
do
   wget $i
done
dcmodify -nb -i "(0010,0010)=CASE_1" -i "(0010,0020)=00001" -i "(0008,0050)=00001" *.dcm
cd ..


mkdir case_2
cd case_2
declare -a arr=(
"https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0001-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0002-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0003-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0004-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0005-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0006-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0007-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0008-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0009-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0010-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0011-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0012-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0013-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0014-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0015-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0016-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0017-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0018-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0019-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0020-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0021-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0022-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0023-0001-11.dcm" "https://web.archive.org/web/20200217130203/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0024-0001-11.dcm"
)
for i in "${arr[@]}"
do
   wget $i
done
dcmodify -nb -i "(0010,0010)=CASE_2" -i "(0010,0020)=00002" -i "(0008,0050)=00002" *.dcm
cd ..


mkdir case_3
cd case_3
declare -a arr=(
"https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0001-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0002-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0003-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0004-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0005-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0006-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0007-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0008-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0009-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0010-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0011-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0012-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0013-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0014-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0015-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0016-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0017-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0018-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0019-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0020-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0021-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0022-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0023-0001-3.dcm" "https://web.archive.org/web/20200217130012/http://learnprostatemri.com/wp-content/uploads/2016/12/IM-0001-0024-0001-3.dcm"
)
for i in "${arr[@]}"
do
   wget $i
done
dcmodify -nb -i "(0010,0010)=CASE_3" -i "(0010,0020)=00003" -i "(0008,0050)=00003" *.dcm
cd ..

echo ""
echo "Sample data saved in folder /sampledata"
echo ""
