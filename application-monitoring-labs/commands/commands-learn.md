tee  : to run the output and saving the output in a file side by side
example: 
 ubuntu@ip-172-31-67-224:~/self-healing-script$ terraform destroy --auto-approve | tee destroy.txt

trivy : used to check the vernabilities in the code like passwords, access keys etc.
example
    trivy fs <location of the repo which is needed to scan>

cat -n <name of the file> : prints the number againt the lines in the out.