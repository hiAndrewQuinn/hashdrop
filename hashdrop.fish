#!/usr/bin/fish

# Set strict error handling
set fish_exit_on_error 1
set fish_pipestatus 1

# Function to display help text
function show_help
    echo "Usage: hashdrop.fish [options] file1 [file2 ...]"
    echo ""
    echo "Options:"
    echo "  --no-header         Do not print the CSV header"
    echo "  --no-timestamp      Do not include a timestamp (overrides --epoch-timestamp)"
    echo "  --epoch-timestamp   Use Unix epoch seconds for the timestamp"
    echo "  -h, --help          Show this help message"
end

# Function to calculate hashes and output in CSV format
function calculate_hashes
    set print_header 1
    set include_timestamp 1
    set timestamp_type iso-8601 # default timestamp type

    # Check for options
    for arg in $argv
        switch $arg
            case --no-header
                set print_header 0
            case --no-timestamp
                set include_timestamp 0
            case --epoch-timestamp
                set timestamp_type epoch
            case -h --help
                show_help
                return 0
        end
    end

    # Remove options from arguments
    set -l files (string match -v -- '--*' $argv)

    # Check if any file arguments were passed
    if test (count $files) -eq 0
        show_help
        return 1
    end

    # Print the CSV header if the option is enabled
    if test $print_header -eq 1
        if test $include_timestamp -eq 1
            echo "Timestamp,MD5,SHA-1,SHA-512"
        else
            echo "MD5,SHA-1,SHA-512"
        end
    end

    # Loop through each file passed as arguments
    for file in $files
        # Ensure the file exists
        if not test -f $file
            echo "File not found: $file"
            continue
        end

        # Calculate hashes
        set md5 (md5sum $file | awk '{print $1}')
        set sha1 (sha1sum $file | awk '{print $1}')
        set sha512 (sha512sum $file | awk '{print $1}')

        # Handle the timestamp based on user preference
        set timestamp ""
        if test $include_timestamp -eq 1
            switch $timestamp_type
                case iso-8601
                    set timestamp (date --iso-8601=seconds)
                case epoch
                    set timestamp (date +%s)
            end
            echo "$timestamp,$md5,$sha1,$sha512"
        else
            echo "$md5,$sha1,$sha512"
        end
    end
end

# Call the function with all arguments passed to the script
calculate_hashes $argv
