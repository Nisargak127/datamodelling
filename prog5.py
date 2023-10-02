import pymongo

# Establish a connection to MongoDB
client = pymongo.MongoClient("mongodb://127.0.0.1:27017/")
db = client["mydatabase"]
collection = db["student"]

def create_record():
        usn = input("Enter USN: ")
        name = input("Enter name: ")
        age = int(input("Enter age: "))
        address = input("Enter Address: ")
        addhar = input("Enter Aadhar Number: ")
        record = {"usn": usn, "name": name, "age": age, "address": address, "addhar": addhar}
        collection.insert_one(record)
        print("Record created successfully!")

def read_records():
        for record in collection.find():
                if 'usn' in record:
                        usn = record['usn']
                else:
                        usn = "N/A"

                if 'name' in record:
                        name = record['name']
                else:
                        name = "N/A"

                if 'age' in record:
                        age = record['age']
                else:
                        age = "N/A"

                if 'address' in record:
                        address = record['address']
                else:
                        address = "N/A"

                if 'addhar' in record:
                        addhar = record['addhar']
                else:
                        addhar = "N/A"

                print(f"USN: {usn}, Name: {name}, Age: {age}, Address: {address}, Aadhar: {addhar}")

def update_record():
        usn_to_update = input("Enter the USN to update: ")
        print("\t")
        while True:
                print("\nSelect the Field to update:")
                print("1. usn")
                print("2. name")
                print("3. age")
                print("4. address")
                print("5. aadhar")
                print("6. Exit")

                choice = input("Enter your choice: ")

                if choice == "1":
                        new_usn = input("Enter the new usn: ")
                        collection.update_one({"usn": usn_to_update}, {"$set": {"usn": new_usn}})
                elif choice == "2":
                        new_name = input("Enter the new Name: ")
                        collection.update_one({"usn": usn_to_update}, {"$set": {"name": new_name}})

                elif choice == "3":
                        new_age = input("Enter the new Age: ")
                        collection.update_one({"usn": usn_to_update}, {"$set": {"age": new_age}})

                elif choice == "4":
                        new_address = input("Enter the new Address: ")
                        collection.update_one({"usn": usn_to_update}, {"$set": {"address": new_address}})

                elif choice == "5":
                        new_addhar = input("Enter the new Addhar: ")
                        collection.update_one({"usn": usn_to_update}, {"$set": {"addhar": new_addhar}})

                elif choice == "6":
                        break
                else:
                        print("Invalid choice")
        print("Successfully Updated")
def delete_record():
        usn_to_delete = input("Enter the USN to delete: ")
        collection.delete_one({"usn": usn_to_delete})
        print("Record deleted successfully!")

while True:
        print("\nMenu:")
        print("1. Create Record")
        print("2. Read Records")
        print("3. Update Record")
        print("4. Delete Record")
        print("5. Exit")

        choice = input("Enter your choice: ")

        if choice == "1":
                create_record()
        elif choice == "2":
                read_records()
        elif choice == "3":
                update_record()
        elif choice == "4":
                delete_record()
        elif choice == "5":
                break
        else:
                print("Invalid choice.")

