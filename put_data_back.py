import numpy as np
import pandas as pd

test = pd.read_csv("filtered_test.txt", sep="\t")

test1 = test[test['year'] == 11]
test2 = test[test['year'] == 12]

months = test1['month'].unique()


#Separate by year
gtest_by_months1 = []
for i in months:
	temp = test1[test1['month'] == i]
	gtest_by_months1.append(temp.groupby('hour'))

#print(gtest_by_months[0].get_group(0).append(gtest_by_months[0].get_group(1)))
gtest_by_months2 = []
for i in months:
	temp = test2[test2['month'] == i]
	gtest_by_months2.append(temp.groupby('hour'))






final_data_frame1 = pd.DataFrame(columns = test.columns)
for i in gtest_by_months1:
	for j in range(24):
		final_data_frame1 = final_data_frame1.append(i.get_group(j))

final_data_frame2 = pd.DataFrame(columns = test.columns)
for i in gtest_by_months2:
	for j in range(24):
		final_data_frame2 = final_data_frame2.append(i.get_group(j))	


final_data_frame = final_data_frame1.append(final_data_frame2)

print(final_data_frame)


counts11 = pd.read_csv("weird_idea2011.txt")
counts12 = pd.read_csv("weird_idea2012.txt")
counts = counts11.append(counts12)


final_data_frame['count'] = counts['count'].as_matrix()
final_data_frame = final_data_frame.sort_index()

sub = pd.read_csv("sampleSubmission.csv")

sub['count'] = final_data_frame['count']

print(final_data_frame)

sub.to_csv("ohgodfinallydone.csv", index=False)