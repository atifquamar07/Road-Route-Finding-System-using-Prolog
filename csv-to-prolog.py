import pandas as pd
from geopy.distance import geodesic
from geopy.geocoders import Nominatim

df = pd.read_csv("roaddistance.csv") 
 
lst = []

sett = set()

temp = ['Ahmedabad','Bangalore','Bhubaneshwar','Bombay','Calcutta','Chandigarh','Cochin','Delhi','Hyderabad','Indore','Jaipur','Kanpur','Lucknow','Madras','Nagpur','Nasik','Panjim','Patna','Pondicherry','Pune']

for i in range(len(df)):
    for j in range(20):
        if(df.iloc[i, j+1] == '-'):
            continue
        
        s = ""
        s+=df['Cities'][i].lower()
        s+=temp[j].lower()
        
        t = ""
        t+=temp[j].lower()
        t+=df['Cities'][i].lower()
        
        l = []
        l.append(df['Cities'][i].lower())
        l.append(temp[j].lower())
        l.append(df.iloc[i, j+1])
        if (s not in sett):
            lst.append(l)
            sett.add(s)
        
        
        r = []
        r.append(temp[j].lower())
        r.append(df['Cities'][i].lower())
        r.append(df.iloc[i, j+1])
        if(t not in sett):
            lst.append(r)
            sett.add(t)
        
        
fd_distances = open("distance.pl", "w")

for i in lst:
    ans = ""
    ans+="distance("
    ans+=i[0]
    ans+=", "
    ans+=i[1]
    ans+=", "
    ans+=str(i[2])
    ans+=")."
    ans+="\n"
    fd_distances.write(ans)


allcities = ['Allahabad', 'Bangalore', 'Indore', 'Delhi', 'Pondicherry', 'Imphal', 'Trivandrum', 'Gwalior', 'Bhubaneshwar', 'Meerut', 'Calcutta', 'Madurai', 'Ranchi', 'Ludhiana', 'Patna', 'Nagpur', 'Agra', 'Shillong', 'Jaipur', 'Asansol', 'Jabalpur', 'Kanpur', 'Madras', 'Nasik', 'Bhopal', 'Baroda', 'Hubli', 'Lucknow', 'Jamshedpur', 'Kolhapur', 'Calicut', 'Shimla', 'Cochin', 'Bombay', 'Vijayawada', 'Ahmedabad', 'Amritsar', 'Coimbatore', 'Hyderabad', 'Pune', 'Jullundur', 'Vishakapatnam', 'Panjim', 'Agartala', 'Chandigarh', 'Varanasi', 'Surat']

    
fd_heuristics = open("heuristics.pl", "w")
geolocator = Nominatim(user_agent="Temp", timeout = 1000)

ctr = 0
for i in range(len(allcities)):
    for j in range(len(allcities)):
        print(str(ctr) + " : " + allcities[i] + " " + allcities[j])
        place1 = geolocator.geocode(allcities[i].lower())
        place2 = geolocator.geocode(allcities[j].lower())
        l1 = (place1.latitude, place1.longitude)
        l2 = (place2.latitude, place2.longitude)
        distance = int(geodesic(l1,l2).km)
        ans = ""
        ans+="heuristics("
        ans+=allcities[i].lower()
        ans+=", "
        ans+=allcities[j].lower()
        ans+=", "
        hVal = distance
        ans+=str(hVal)
        ans+=")."
        ans+="\n"

        fd_heuristics.write(ans)
        ctr+=1

print("Data written in distances.pl")
print("Data written in heuristics.pl")
    