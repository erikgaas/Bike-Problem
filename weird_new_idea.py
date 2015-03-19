import numpy as np
import pandas as pd
#Pick ML algorithm
from sklearn import svm

train = pd.read_csv("filtered_train.txt", sep="\t")
train = train[train['year'] == 11]
#grab the unique month names in order
months = train['month'].unique()

#######
#Here we need the test data
test = pd.read_csv("filtered_test.txt", sep="\t")
test = test[test['year'] == 11]
gtest_by_months = []
for i in months:
	temp = test[test['month'] == i]
	gtest_by_months.append(temp.groupby('hour'))
#######



#Get each month independently and group them by time
g_by_months = []
for i in months:
	temp = train[train['month'] == i]
	g_by_months.append(temp.groupby('hour'))


cas_reg = []
for count_type in ['registered', 'casual']:
	curr_count = []
	#For every month for both train and test
	for month in range(len(g_by_months)):
		print(months[month])
		#Look at every time group
		for t in range(0,24):
			print(t)
			#grab that t_group
			temp = g_by_months[month].get_group(t)
			#get rid of the weekday, month, year, hour information
			temp = temp.drop(['weekday', 'month', 'year', 'hour'], axis=1)
			#we will just care about casual right now CHANGE THIS LATER
			temp = temp.drop(count_type, axis=1)

			train_array = np.empty([1, len(temp.columns)-1])
			labels_array = np.empty([1,1])
			#for every row in this new dataframe
			for _ , row1 in temp.iterrows():
				row1 = row1.as_matrix()
				for _ , row2 in temp.iterrows():
					row2 = row2.as_matrix()
					new_row = row1 - row2
					dat = new_row[0:-1]
					label = new_row[-1]
					train_array = np.vstack([train_array, dat])
					labels_array = np.append(labels_array, label)

			#We know have train and labels for data at particular time and month
			#Now implement ML on this data.
			clf = svm.SVR()
			train_array = np.around(train_array, decimals=3)
			labels_array = np.around(labels_array, decimals=1)
			where_are_NaNs = np.isnan(labels_array)
			labels_array[where_are_NaNs] = 0

			clf.fit(train_array, labels_array)

			#retrieve group for test dataset THS COMES BACK LATER
			curr_test = gtest_by_months[month].get_group(t)


			#The data information is important here. Need to keep that for submission
			copy_cur_test = curr_test.copy()
			copy_cur_test = copy_cur_test.drop(['weekday', 'month', 'year', 'hour'], axis=1)

			
			#For every element in cur_test_mat
			test = copy_cur_test.iterrows()


			for _ , row in copy_cur_test.iterrows():
				subtract_matrix = np.empty([1, len(temp.columns)-1])
				subtract_labels = np.empty([1,1])
				#for every row in train_array
				for _, t_row in temp.iterrows():
					#TRYING NEW THING SEEING IF IT WORKS
					new_row = row.as_matrix() - t_row.as_matrix()[0:-1]# - row.as_matrix()
					subtract_matrix = np.vstack([subtract_matrix, new_row])
					subtract_labels = np.append(subtract_labels, t_row.as_matrix()[-1])


				subtract_matrix = np.around(subtract_matrix, decimals=3)
				#print(subtract_matrix)

				# print("here is what we have for", month, t, "for the first" + str(t) + "hour")

				pred = clf.predict(subtract_matrix)
				# print(pred)
				# print(subtract_labels)
				real_pred = pred + subtract_labels
				avg_pred = np.round(np.average(real_pred))

				if avg_pred < 0:
					avg_pred = 0
				else:
					avg_pred = int(avg_pred)
				curr_count.append(avg_pred)
				# asdfasdf
	cas_reg.append(curr_count)





total_count = []
for i in range(len(cas_reg[0])):
	total_count.append(cas_reg[0][i] + cas_reg[1][i])

finally_done = open("weird_idea2011.txt", "w")
finally_done.write("count"+"\n")
for i in total_count:
	finally_done.write(str(i) + "\n")
finally_done.close()