package terraform.cloudtrail
import rego.v1

result := {"passed": count(violations) == 0, "messages": violations}

is_after(rc) if { is_object(rc.change.after) }

# helper
has_kms(rc) if {
  is_after(rc)
  a := rc.change.after
  a.kms_key_id
  not is_null(a.kms_key_id)
}
has_kms(rc) if {
  is_after(rc)
  u := rc.change.after_unknown
  u.kms_key_id == true
}

# multi-region
violations contains msg if {
  rc := input.resource_changes[_]
  rc.type == "aws_cloudtrail"
  is_after(rc)
  not rc.change.after.is_multi_region_trail
  msg := sprintf("CloudTrail %q must be multi-region.", [rc.address])
}

# KMS required (use has_kms)
violations contains msg if {
  rc := input.resource_changes[_]
  rc.type == "aws_cloudtrail"
  is_after(rc)
  not has_kms(rc)
  msg := sprintf("CloudTrail %q must use KMS CMK (kms_key_id).", [rc.address])
}

# log file validation
violations contains msg if {
  rc := input.resource_changes[_]
  rc.type == "aws_cloudtrail"
  is_after(rc)
  not rc.change.after.enable_log_file_validation
  msg := sprintf("CloudTrail %q must enable log file validation.", [rc.address])
}
