#!/bin/bash

echo "⚠️  WARNING: This will delete ALL Load Balancers, VPC resources, and EC2 'other' resources!"
echo "This action is IRREVERSIBLE!"


echo "Starting cleanup across all regions..."

# Run the deletion scripts in order
echo "1. Deleting Load Balancers..."

regions=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output text)

for region in $regions; do
    echo "Deleting Load Balancers in region: $region"
    export AWS_DEFAULT_REGION=$region
    
    # Delete ALB/NLB Load Balancers
    echo "Deleting ALB/NLB..."
    aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --output text 2>/dev/null | \
    xargs -r -n1 -I{} aws elbv2 delete-load-balancer --load-balancer-arn {}
    
    # Delete Classic Load Balancers
    echo "Deleting Classic LB..."
    aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName' --output text 2>/dev/null | \
    xargs -r -n1 -I{} aws elb delete-load-balancer --load-balancer-name {}
    
    # Wait a moment for LBs to delete before deleting target groups
    sleep 10
    
    # Delete Target Groups (orphaned ones)
    echo "Deleting Target Groups..."
    aws elbv2 describe-target-groups --query 'TargetGroups[*].TargetGroupArn' --output text 2>/dev/null | \
    xargs -r -n1 -I{} aws elbv2 delete-target-group --target-group-arn {}
done

echo "2. Deleting EC2 Other resources..."

regions=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output text)

for region in $regions; do
    echo "Deleting EC2 Other resources in region: $region"
    export AWS_DEFAULT_REGION=$region
    
    # Delete unattached EBS volumes
    echo "Deleting unattached EBS volumes..."
    aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[*].VolumeId' --output text 2>/dev/null | \
    xargs -r -n1 -I{} aws ec2 delete-volume --volume-id {}
    
    # Delete EBS snapshots (your own)
    echo "Deleting EBS snapshots..."
    aws ec2 describe-snapshots --owner-ids self --query 'Snapshots[*].SnapshotId' --output text 2>/dev/null | \
    xargs -r -n1 -I{} aws ec2 delete-snapshot --snapshot-id {}
    
    # Release unassociated Elastic IPs
    echo "Releasing Elastic IPs..."
    aws ec2 describe-addresses --query 'Addresses[?AssociationId==null].AllocationId' --output text 2>/dev/null | \
    xargs -r -n1 -I{} aws ec2 release-address --allocation-id {}
    
    # Delete AMIs and associated snapshots
    echo "Deregistering AMIs..."
    aws ec2 describe-images --owners self --query 'Images[*].ImageId' --output text 2>/dev/null | \
    xargs -r -n1 -I{} aws ec2 deregister-image --image-id {}
    
    # Delete Key Pairs
    echo "Deleting Key Pairs..."
    aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output text 2>/dev/null | \
    xargs -r -n1 -I{} aws ec2 delete-key-pair --key-name {}
done

echo "3. Deleting VPC resources..."

regions=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output text)

for region in $regions; do
    echo "Deleting VPC resources in region: $region"
    export AWS_DEFAULT_REGION=$region
    
    # Get all non-default VPCs
    vpcs=$(aws ec2 describe-vpcs --filters Name=is-default,Values=false --query 'Vpcs[*].VpcId' --output text 2>/dev/null)
    
    for vpc in $vpcs; do
        echo "Processing VPC: $vpc"
        
        # Delete NAT Gateways first (they take time)
        echo "Deleting NAT Gateways in VPC $vpc..."
        aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=$vpc --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text 2>/dev/null | \
        xargs -r -n1 -I{} aws ec2 delete-nat-gateway --nat-gateway-id {}
        
        # Delete VPC Endpoints
        echo "Deleting VPC Endpoints in VPC $vpc..."
        aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values=$vpc --query 'VpcEndpoints[*].VpcEndpointId' --output text 2>/dev/null | \
        xargs -r -n1 -I{} aws ec2 delete-vpc-endpoint --vpc-endpoint-id {}
        
        # Delete EC2 instances in this VPC
        echo "Terminating instances in VPC $vpc..."
        aws ec2 describe-instances --filters Name=vpc-id,Values=$vpc Name=instance-state-name,Values=running,stopped --query 'Reservations[*].Instances[*].InstanceId' --output text 2>/dev/null | \
        xargs -r -n1 -I{} aws ec2 terminate-instances --instance-ids {}
    done
    
    # Wait for NAT Gateways to delete (they take several minutes)
    echo "Waiting for NAT Gateways to delete..."
    sleep 180
    
    for vpc in $vpcs; do
        echo "Continuing cleanup for VPC: $vpc"
        
        # Delete Security Groups (non-default)
        echo "Deleting Security Groups in VPC $vpc..."
        aws ec2 describe-security-groups --filters Name=vpc-id,Values=$vpc --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text 2>/dev/null | \
        xargs -r -n1 -I{} aws ec2 delete-security-group --group-id {}
        
        # Delete Subnets
        echo "Deleting Subnets in VPC $vpc..."
        aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc --query 'Subnets[*].SubnetId' --output text 2>/dev/null | \
        xargs -r -n1 -I{} aws ec2 delete-subnet --subnet-id {}
        
        # Delete Route Tables (non-main)
        echo "Deleting Route Tables in VPC $vpc..."
        aws ec2 describe-route-tables --filters Name=vpc-id,Values=$vpc --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text 2>/dev/null | \
        xargs -r -n1 -I{} aws ec2 delete-route-table --route-table-id {}
        
        # Delete Network ACLs (non-default)
        echo "Deleting Network ACLs in VPC $vpc..."
        aws ec2 describe-network-acls --filters Name=vpc-id,Values=$vpc --query 'NetworkAcls[?IsDefault==`false`].NetworkAclId' --output text 2>/dev/null | \
        xargs -r -n1 -I{} aws ec2 delete-network-acl --network-acl-id {}
        
        # Detach and Delete Internet Gateways
        echo "Deleting Internet Gateways for VPC $vpc..."
        aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$vpc --query 'InternetGateways[*].InternetGatewayId' --output text 2>/dev/null | \
        xargs -r -n1 -I{} sh -c 'aws ec2 detach-internet-gateway --internet-gateway-id {} --vpc-id '$vpc'; aws ec2 delete-internet-gateway --internet-gateway-id {}'
        
        # Finally, delete the VPC
        echo "Deleting VPC $vpc..."
        aws ec2 delete-vpc --vpc-id $vpc 2>/dev/null || echo "Failed to delete VPC $vpc - may have dependencies"
    done
done

echo "Cleanup complete. Please check the AWS console to verify all resources are deleted."
echo "Note: Some resources may take several minutes to fully delete."





echo "Checking if cleanup was successful..."

regions=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output text)

for region in $regions; do
    export AWS_DEFAULT_REGION=$region
    
    lb_count=$(aws elbv2 describe-load-balancers --query 'length(LoadBalancers)' --output text 2>/dev/null || echo "0")
    classic_lb_count=$(aws elb describe-load-balancers --query 'length(LoadBalancerDescriptions)' --output text 2>/dev/null || echo "0")
    nat_count=$(aws ec2 describe-nat-gateways --query 'length(NatGateways[?State!=`deleted`])' --output text 2>/dev/null || echo "0")
    vpc_count=$(aws ec2 describe-vpcs --filters Name=is-default,Values=false --query 'length(Vpcs)' --output text 2>/dev/null || echo "0")
    
    if [ "$lb_count" != "0" ] || [ "$classic_lb_count" != "0" ] || [ "$nat_count" != "0" ] || [ "$vpc_count" != "0" ]; then
        echo "Region $region still has resources: ALB/NLB:$lb_count, Classic LB:$classic_lb_count, NAT:$nat_count, VPC:$vpc_count"
    fi
done
