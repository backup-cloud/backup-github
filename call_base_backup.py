import json
import sys
from backup_cloud import BackupContext

def main_function(filename):

    ssm_path = "/backup_cloud/base_defs"
    file_in = filename
    file_out = filename + ".gpg"

    bc = BackupContext(ssm_path=ssm_path)
    backup_context = bc

    backup_context.run(["fixtures/encrypt_file.sh"])

    with open(file_out, "rb") as data_file:
        encrypted_file_contents = data_file.read()

if __name__ == "__main__":
    main_function(sys.argv[1])
    