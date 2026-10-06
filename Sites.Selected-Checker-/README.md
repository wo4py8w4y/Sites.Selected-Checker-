# Sites Selected Checker

## Step-by-Step Help Section

1. **Prerequisites**:
   - Ensure you have PowerShell installed on your machine.
   - Install the Microsoft Graph PowerShell SDK by running the command: 
     ```
     Install-Module Microsoft.Graph -Scope CurrentUser
     ```

2. **Clone the Repository**:
   - Open your terminal or PowerShell.
   - Clone the repository using the command:
     ```
     git clone https://github.com/wo4py8w4y/Sites.Selected-Checker-.git
     ```
   - Navigate to the project directory:
     ```
     cd Sites.Selected-Checker-
     ```

3. **Running the Smoke Test**:
   - Open PowerShell as an administrator.
   - Execute the smoke test harness script:
     ```
     .\smoke_check_harness.ps1
     ```
   - Review the output for the results of the smoke test. Look for `SMOKE_TEST_RESULT=PASS` or `SMOKE_TEST_RESULT=FAIL` to determine the outcome.

4. **Using the Main Script**:
   - To use the main functionality of the application, run the following command in PowerShell:
     ```
     .\Sites.Selected-Checker.ps1
     ```
   - Follow any prompts or instructions that appear in the console.

5. **Modifying the Scripts**:
   - You can edit the scripts using any text editor or PowerShell ISE to customize the functionality as needed.
   - Ensure to test any changes using the smoke test harness to verify that everything works as expected.

6. **Troubleshooting**:
   - If you encounter issues, check the error messages in the console for guidance.
   - Ensure that you have the necessary permissions to access Microsoft Graph resources.
   - Consult the Microsoft Graph documentation for additional information on API usage.

7. **Contributing**:
   - If you would like to contribute to the project, please fork the repository and create a pull request with your changes.
   - Ensure that your code adheres to the project's coding standards and includes appropriate tests.

8. **License**:
   - This project is licensed under the MIT License. See the LICENSE file for more details.

By following these steps, you should be able to set up and run the Sites Selected Checker project successfully.