# Multi-Cloud DR Platform: Threat Model

## Threat Actors & Vectors
1. **Compromised CI/CD Pipeline:** Mitigated via OIDC federation (Zero-Trust). No static keys exist to be exfiltrated.
2. **State Manipulation:** Mitigated via GCS object versioning and public access prevention.
3. **Cross-Cloud Lateral Movement:** Mitigated via strict CIDR isolation preventing overlapping IP space.
