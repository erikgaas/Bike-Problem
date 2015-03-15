file_in = open('train.txt','rt')
file_out = open('filtered_train.txt','wt')


for line in file_in:
	line=line.rstrip()
	row= line.split('\t')
	row[0]=row[0][1:-1]
	big_row = list(row[0].split(','))
	weekday=big_row[0]
	if 'Saturday' in weekday or 'Sunday' in weekday:
		is_weekend = 1
	else:
		is_weekend = 0
	month_date = big_row[1]
	month_date = month_date.split(' ')
	month = month_date[1]
	date = month_date[2]
	year = big_row[2]

	solution = "\t".join([weekday,month,date,year,str(is_weekend)])+"\t"+"\t".join(row[1:])

	print(solution,file=file_out)



file_in.close()
file_out.close()
