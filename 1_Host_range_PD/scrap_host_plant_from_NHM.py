from bs4 import BeautifulSoup
from selenium import webdriver
driver = webdriver.Chrome("/Applications/chromedriver")

#read in the csv prepared by Even
URLs=open('HOST_rec_Even.csv').readlines()
out1=open('HOST_genus_raw_multiple_lines.csv','a')

for line in URLs:
	URL=line.split(',')[-1]
	URL=URL.strip()
	lep_genus=line.split(',')[2]
	lep_sp=line.split(',')[3]
	#acquire webpage
	#driver.get("https://www.nhm.ac.uk/our-science/data/hostplants/search/list.dsml?Genus=Danaus&with&Species=plexippus")
	#driver.get("https://www.nhm.ac.uk/our-science/data/hostplants/search/list.dsml?Genus=Acanthopteroctetes&with&Species=unifascia")
	driver.get(URL)
	soup = BeautifulSoup(driver.page_source)
	
	#find host plant table
	host_list=soup.find_all('table',attrs={'class':'collapseParas dataTable_ms'})
	#get info from each record
	try:
		HRs=host_list[0].find_all('tr')
	except IndexError:
		out1.write(line.split(',')[0]+',0,0\n')
		continue
	for i in range(1,len(HRs)):
		rec=HRs[i].get_text().split('\n')
		host_family = rec[3]
		host_sp=rec[4]
		#print(line.split(',')[0],host_family,host_sp)
		out1.write(line.split(',')[0]+','+host_family+','+host_sp+'\n')
			
	#get number of records, check if they are on multiple pages
	pages=soup.find_all('td',attrs={'class':'pageTable','align':'center'})
	if pages:
		#multiple pages
		page_num=pages[0].text.split()
		for j in range(1,len(page_num)):
			driver.get("https://www.nhm.ac.uk/our-science/data/hostplants/search/list.dsml?Species="+lep_sp+"&beginIndex="+str(30*j)+"&Genus="+lep_genus+"&")
			soup = BeautifulSoup(driver.page_source)
			host_list=soup.find_all('table',attrs={'class':'collapseParas dataTable_ms'})
			HRs=host_list[0].find_all('tr')
			for i in range(1,len(HRs)):
				rec=HRs[i].get_text().split('\n')
				host_family = rec[3]
				host_sp=rec[4]
				out1.write(line.split(',')[0]+','+host_family+','+host_sp+'\n')
			
out1.close()

#remove redundant records in out1 to create a nonredundant, multiple line csv
out2=open('HOST_genus_nonredundant_at_genus_level_multiple_lines.csv','a')

out1=open('HOST_genus_raw_multiple_lines.csv').readlines()
HR={}
for l in out1:
	l=l.strip()
	l=l.split(',')
	try:
		HR_sp=l[2].split()[0]
	except IndexError:
		HR_sp='0'
	if not l[0] in HR.keys():
		#new lep sp record
		HR[l[0]]={l[1]:[HR_sp]}
	else:
		if not l[1] in HR[l[0]].keys():
			#new host family
			HR[l[0]]={l[1]:[HR_sp]}
		else:
			if not HR_sp in HR[l[0]][l[1]]:
				#new genus in this family
				HR[l[0]][l[1]].append(HR_sp)

for k in HR.keys():
	for kk in HR[k].keys()
		for j in HR[k][kk]:
			out2.write(k+','+kk+','+j+'\n')

#out3=open('HOST_genus_nonredundant_one_line.csv','a')


