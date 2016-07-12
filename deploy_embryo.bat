ECHO cd /home/f_gaed01/Projects/EmbryoProject > commands.txt
ECHO git pull origin master >> commands.txt
ECHO logout >> commands.txt
plink f_gaed01@bregman -pw Fendor1992 < commands.txt
del commands.txt
