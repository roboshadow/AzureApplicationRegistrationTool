# AzureApplicationRegistrationTool
Tool that makes it easy to create an azure application for RoboShadow Syncing.

Step 1:
Download the repository and extract.
Right click the powershell script and press "Run with PowerShell"
![image](https://user-images.githubusercontent.com/77623363/170296943-a985ba23-f982-4005-9fba-4ecd4da1b846.png)

Step 2:
The script will self-elevate itself to require Administrator consent in order to install the Az module if it hasn't been installed already.

Step 3:
After the module has imported or downloaded, you will be required to sign into a Global Administrator account.
![image](https://user-images.githubusercontent.com/77623363/170297333-55d092ca-a3be-46a2-900f-e08deac7c084.png)

Step 4:
If you have setup the RoboShadow App Registration previously, the script may detect it already exists and will ask you to confirm before replacing the old one.
![image](https://user-images.githubusercontent.com/77623363/170297568-52328157-469d-482a-aa80-ccc71b54f924.png)

Step 5:
After the application has finished creating and updating the permissions, it waits 60 seconds for Microsoft to create everything on the backend.
![image](https://user-images.githubusercontent.com/77623363/170297768-702fb678-688e-4688-9c98-922baafee750.png)

Step 6:
A new tab will be opened on your default browser, please sign in with the same Global Administrator account to consent to the permissions.
![image](https://user-images.githubusercontent.com/77623363/170298020-bce72e3e-d5a5-4870-8950-be6f645c9c1c.png)

Step 7:
You will be automatically redirected to the Roboshadow Portal, and if you look back at the powershell window, the 3 required values are outputted for you to use when setting up AD Sync.
![image](https://user-images.githubusercontent.com/77623363/170298243-73faf97e-bfe1-4cde-bb7b-b0b1b63c5a62.png)
![image](https://user-images.githubusercontent.com/77623363/170298495-445de3d1-7afa-460f-9c4b-23e1ea439360.png)
