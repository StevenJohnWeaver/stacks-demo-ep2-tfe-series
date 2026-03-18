# Sentinel Policy Set Configuration
policy_set "ep2-guardrails" {
  policy "allowed-instance-types" {
    enforcement_level = "hard-mandatory"
  }

  policy "require-tags" {
    enforcement_level = "soft-mandatory"
  }
}
