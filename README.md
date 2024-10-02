# TrashSweep App

TrashSweep is an application designed to manage and clean up your trash directory using the FIFO (First In, First Out) rule. This ensures that the oldest files are deleted first, keeping your trash directory within a user-defined size limit.

## Features

- **FIFO Trash Management**: Automatically deletes the oldest files first to maintain the trash size within the specified limit.
- **User-Defined Trash Size**: Allows users to set a maximum size for the trash directory.

## How It Works

1. **FIFO Rule**: The application monitors the trash directory and deletes the oldest files first when the total size exceeds the user-defined limit.
2. **Configurable Trash Size**: Users can specify the maximum size for the trash directory. The app will ensure that the total size of files in the trash does not exceed this limit.

## Usage

1. **Set Trash Size**: Define the maximum size for your trash directory in the app settings.
2. **Automatic Cleanup**: The app will automatically manage the trash directory, deleting the oldest files first to keep the total size within the specified limit.

## Updates

For the latest updates and release notes, please refer to the [appcast.xml](https://example.com/appcast.xml) file.

## License

This project is licensed under the MIT License.
