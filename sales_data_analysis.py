import pandas as pd
from sqlalchemy import create_engine

#read data from file into dataframe and handle null values
print("reading csv file")
df = pd.read_csv('orders.csv', na_values=['Not Available', 'unknown'])

#display the first 5 rows
print(df.head())

#replace spaces in column names woth underscore and convert to lower case
df.columns=df.columns.str.replace(' ','_')
df.columns=df.columns.str.lower()

print(df.head())

#derive new columns discount , sale price and profit
df['discount']=df['list_price']*df['discount_percent']*.01
df['sale_price']= df['list_price']-df['discount']
df['profit']=df['sale_price']-df['cost_price']

print("printing DF after new columns")
print(df.head())

#drop cost price list price and discount percent columns
df.drop(columns=['list_price','cost_price','discount_percent'],inplace=True)

# Database connection configuration
user = ''
password = ''
host = ''
database = ''

# Create SQLAlchemy engine
engine = create_engine(f"mysql+mysqlconnector://{user}:{password}@{host}/{database}")

# Write DataFrame to SQL table
try:
    df.to_sql('df_orders', con=engine, index=False, if_exists='append')
    print("Data successfully written to the table!")
except Exception as e:
    print(f"Error: {e}")