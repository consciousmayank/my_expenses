const String ksHomeBottomSheetTitle = 'Build Great Apps!';
const String ksHomeBottomSheetDescription =
    'Stacked is built to help you build better apps. Give us a chance and we\'ll prove it to you. Check out stacked.filledstacks.com to learn more';
const String ksNewExpense = '[Add New Expense]';
const String ksNameRequired = 'Name is required';
const String ksAmountRequired = 'Amount is required';
const String ksAmountMustBeGreaterThanZero = 'Amount must be greater than 0';
const String ksFileName = 'expense_manager_backup.json';
const String ksFetchDataFromGdrive =
    'Do you want to fetch your previous expense data from Google Drive?';

const String ksBusyObjectFetchDataFromGdrive = 'fetchDataFromGdrive';

// Drive Backup Service Constants
const String ksDriveApiBaseUrl = 'https://www.googleapis.com/drive/v3';
const String ksDriveUploadBaseUrl =
    'https://www.googleapis.com/upload/drive/v3';
const String ksDriveAppFolderName = 'Expense Manager';
const String ksDriveSecretSalt = "your-long-random-string-here";

// Drive Error Messages
const String ksEncryptionNotInitialized =
    'Encryption not initialized. Call initializeEncryption first.';
const String ksFolderCreationError = 'Failed to create or find app folder';
const String ksErrorCreatingFolder = 'Error creating folder: ';
const String ksErrorUploadingFile = 'Error uploading file to Drive: ';
const String ksErrorReadingFile = 'Error reading file from Drive: ';
const String ksErrorListingFiles = 'Error listing files from Drive: ';
const String ksErrorDeletingFile = 'Error deleting file from Drive: ';
const String ksErrorReadingFileByName =
    'Error reading file by name from Drive: ';
const String ksErrorRevokingToken = 'Error revoking access token: ';

// All Expenses ViewModel Constants
const String ksExpenseDeletedSuccessfully = 'Expense deleted successfully';
const String ksErrorDeletingExpense = 'Error deleting expense: ';
const String ksExpenseUpdatedSuccessfully = 'Expense updated successfully';
const String ksErrorUpdatingExpense = 'Error updating expense: ';
const String ksExpenseAddedSuccessfully = 'Expense added successfully';
const String ksErrorAddingExpense = 'Error adding expense: ';
const String ksNoExpensesFound = 'No expenses found';
const String ksErrorLoadingExpenses = 'Error loading expenses: ';
const String ksExpense = 'Expense ';
const String ksSampleExpense = 'Sample expense for ';

// All Expenses View Mobile Constants
const String ksAllExpensesTitle = 'All Expenses';
const String ksNoExpensesMessage = 'No expenses found for the selected period';
const String ksDeleteExpenseConfirmation = 'Delete Expense?';
const String ksDeleteExpenseDescription =
    'Are you sure you want to delete this expense?';
const String ksDelete = 'Delete';
const String ksCancel = 'Cancel';
const String ksEdit = 'Edit';
const String ksAmount = 'Amount: ';
const String ksDescription = 'Description: ';
const String ksSessionExpired = 'Your session has expired. Please login again.';

// Auth Service Constants
const String ksTokenValidationError = 'Token validation error: ';
const String ksGoogleTokenValidationError = 'Google token validation error: ';
const String ksTokenValidationRequestError = 'Token validation request error: ';
