# deployer-iam-policies
Restrictive IAM Policies for the Domino Deployer

These are IAM policies that attempt to minimize the permissions required to perform a Domino deployment.

It is distributed as a terraform module with the following variables:

* aws\_region [required]: AWS region (ie us-west-2)
* stage [default: domino]: Domino Deployment "stage" name (ie "domino-example"); can be a prefix (ie "domino" for "domino-example"), as it's globbed
* create\_user [default: false]: Create an IAM user for deployment, with access keys, associated with these policies
* dev [default: false]: Extra policies for route53 hosted zone support, used for internal development

However, if you want to apply the policies directly you'll want to fill out the one templated variable: stage

You can do this easily for each policy file with sed:
```
cat iam-policy-a.json | sed 's/${stage}/domino/g' > iam-policy-a-complete.txt
cat iam-policy-b.json | sed 's/${stage}/domino/g' > iam-policy-b-complete.txt
```
