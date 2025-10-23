# 🎯 Dolpinder Profile - On-Chain User Profile System

A decentralized user profile system built on Sui blockchain, allowing users to create soulbound profile NFTs with projects and tradeable certificate NFTs.

## 📋 Features

### 🧱 Profile NFT (Soulbound - Non-tradeable)

- ✅ **One profile per address** - Each user can only mint one profile
- ✅ **Immutable ownership** - Profile cannot be transferred or traded
- ✅ **Rich metadata** - Name, bio, avatar, banner, social links
- ✅ **Project tracking** - Store unlimited projects using dynamic fields
- ✅ **Certificate counting** - Track total certificates earned
- ✅ **Verification status** - Admin can verify trusted profiles
- ✅ **Display on Suiscan** - Beautiful display with Sui Display standard

### 🚀 Projects Management (Dynamic Fields)

- ✅ **Unlimited projects** - Add as many projects as you want to your profile
- ✅ **Full CRUD operations** - Add, update, remove projects anytime
- ✅ **Project metadata** - Name, demo link, description, tags, timestamp
- ✅ **Gas efficient** - Projects stored in dynamic fields for optimal gas usage
- ✅ **Indexed access** - Each project has a unique index for easy querying

### 🎓 Certificate NFTs (Tradeable)

- ✅ **Tradeable certificates** - Can be transferred/sold (has `store` ability)
- ✅ **Linked to profile** - Each certificate links back to owner's profile
- ✅ **Rich details** - Title, issuer, issue date, credential ID, description
- ✅ **Certificate URL** - Link to certificate image/PDF from Walrus/IPFS
- ✅ **Display on Suiscan** - Beautiful certificate display with full metadata
- ✅ **Update & burn** - Owner can update details or permanently delete certificates

## 🏗️ Architecture

```
ProfileRegistry (Shared Object)
├── total_profiles: u64
└── minted_users: Table<address, bool>

ProfileNFT (Owned Object - Soulbound)
├── owner: address
├── name, bio, avatar_url, banner_url
├── social_links: vector<string>
├── project_count: u64
├── certificate_count: u64
├── verified: bool
├── created_at: u64
└── projects: Dynamic Fields
    ├── Project[0]: {name, link_demo, description, tags, created_at}
    ├── Project[1]: ...
    └── Project[n]: ...

CertificateNFT (Owned Object - Tradeable)
├── owner: address
├── profile_id: address (linked to ProfileNFT)
├── title, issuer, issue_date
├── certificate_url
├── description, credential_id
└── created_at: u64
```

## 🚀 Deployment

### Build

```bash
sui move build
```

### Deploy to Testnet

```bash
sui client publish --gas-budget 100000000
```

### Save IDs

After deployment, save these IDs:

- **Package ID**: `0x...` - Your deployed package
- **Registry ID**: `0x...` - Shared ProfileRegistry object
- **Display ID**: `0x...` - Display for ProfileNFT
- **Certificate Display ID**: `0x...` - Display for CertificateNFT

## 📝 Usage

### 1️⃣ Mint Profile NFT

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module profiles \
  --function mint_profile \
  --args <REGISTRY_ID> \
    "Your Name" \
    "Your bio description" \
    "https://aggregator.walrus-testnet.walrus.space/v1/<AVATAR_BLOB_ID>" \
    "https://aggregator.walrus-testnet.walrus.space/v1/<BANNER_BLOB_ID>" \
    '["twitter:handle","github:username"]' \
    0x6 \
  --gas-budget 10000000
```

### 2️⃣ Update Profile

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module profiles \
  --function update_profile \
  --args <PROFILE_NFT_ID> \
    "New Name" \
    "New bio" \
    "https://new-avatar-url" \
    "https://new-banner-url" \
    '["twitter:new"]' \
  --gas-budget 10000000
```

### 3️⃣ Add Project

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module profiles \
  --function add_project \
  --args <PROFILE_NFT_ID> \
    "My Project Name" \
    "https://demo.myproject.com" \
    "Project description" \
    '["DeFi","Sui","NFT"]' \
    0x6 \
  --gas-budget 10000000
```

### 4️⃣ Update Project

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module profiles \
  --function update_project \
  --args <PROFILE_NFT_ID> \
    0 \
    "Updated Name" \
    "https://new-demo.com" \
    "New description" \
    '["Updated","Tags"]' \
    0x6 \
  --gas-budget 10000000
```

### 5️⃣ Remove Project

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module profiles \
  --function remove_project \
  --args <PROFILE_NFT_ID> 0 \
  --gas-budget 10000000
```

### 6️⃣ Mint Certificate NFT

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module profiles \
  --function mint_certificate \
  --args <PROFILE_NFT_ID> \
    "Blockchain Developer Certificate" \
    "Sui Foundation" \
    "2025-01-15" \
    "https://aggregator.walrus-testnet.walrus.space/v1/<CERT_BLOB_ID>" \
    "Completed advanced Move programming course" \
    "CERT-2025-001" \
    0x6 \
  --gas-budget 10000000
```

### 7️⃣ Update Certificate

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module profiles \
  --function update_certificate \
  --args <CERTIFICATE_NFT_ID> \
    "Updated Title" \
    "New Issuer" \
    "2025-01-20" \
    "https://new-cert-url" \
    "Updated description" \
    "NEW-ID-001" \
  --gas-budget 10000000
```

### 8️⃣ Burn Certificate

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module profiles \
  --function burn_certificate \
  --args <CERTIFICATE_NFT_ID> \
  --gas-budget 10000000
```

## 🔍 View Functions

### Check if user has minted profile

```typescript
const hasMinted = await client.call({
  target: `${packageId}::profiles::has_minted`,
  arguments: [registryId, userAddress],
});
```

### Get profile info

```typescript
const name = await client.call({
  target: `${packageId}::profiles::name`,
  arguments: [profileNftId],
});

const certificateCount = await client.call({
  target: `${packageId}::profiles::get_certificate_count`,
  arguments: [profileNftId],
});
```

### Get project info

```typescript
const projectCount = await client.call({
  target: `${packageId}::profiles::get_project_count`,
  arguments: [profileNftId],
});

const projectExists = await client.call({
  target: `${packageId}::profiles::project_exists`,
  arguments: [profileNftId, 0], // index 0
});

const project = await client.call({
  target: `${packageId}::profiles::get_project`,
  arguments: [profileNftId, 0],
});
```

### Get certificate info

```typescript
const certTitle = await client.call({
  target: `${packageId}::profiles::certificate_title`,
  arguments: [certificateNftId],
});

const certIssuer = await client.call({
  target: `${packageId}::profiles::certificate_issuer`,
  arguments: [certificateNftId],
});
```

## ⚠️ Error Codes

| Code  | Error          | Description                                   |
| ----- | -------------- | --------------------------------------------- |
| **1** | Already minted | User already has a profile, cannot mint again |
| **2** | Not owner      | Caller is not the owner, permission denied    |
| **3** | Invalid index  | Project index out of bounds                   |

## 🛠️ Technology Stack

- **Blockchain**: Sui
- **Language**: Move
- **Storage**: Dynamic Fields for projects
- **Display**: Sui Display Standard
- **Storage**: Walrus (for images)

## 📊 Smart Contract Structure

```move
module dolpinder_profile::profiles {
    // Main Structs
    public struct ProfileNFT has key { ... }           // Soulbound profile
    public struct ProfileRegistry has key { ... }       // Shared registry
    public struct Project has store, drop { ... }       // Project data
    public struct CertificateNFT has key, store { ... } // Tradeable certificate

    // Entry Functions
    entry fun mint_profile(...)          // Create profile (once per user)
    entry fun update_profile(...)        // Update profile info
    entry fun add_project(...)           // Add new project
    entry fun update_project(...)        // Update project
    entry fun remove_project(...)        // Remove project
    entry fun mint_certificate(...)      // Create certificate
    entry fun update_certificate(...)    // Update certificate
    entry fun burn_certificate(...)      // Destroy certificate

    // View Functions
    public fun has_minted(...)           // Check if user has profile
    public fun get_project_count(...)    // Get total projects
    public fun get_certificate_count(...) // Get total certificates
    public fun project_exists(...)       // Check if project exists
    public fun get_project(...)          // Get project by index
    public fun certificate_title(...)    // Get certificate title
    // ... and many more getters
}
```

## 🎨 Display on Suiscan

### Profile NFT Display

Automatically displays on Suiscan with:

- **Name**: User's display name
- **Description**: User's bio
- **Image**: Avatar URL
- **Project URL**: Custom project website
- **Creator**: "Dolpinder Profile"

### Certificate NFT Display

Automatically displays on Suiscan with:

- **Name**: Certificate title
- **Description**: Certificate description
- **Image**: Certificate image/PDF from Walrus
- **Issuer**: Organization that issued the certificate
- **Issue Date**: Date the certificate was issued
- **Credential ID**: Unique certificate identifier
- **Creator**: "Dolpinder Profile"

## 🔐 Security Features

1. **Soulbound Profile**: Profile NFT cannot be transferred or traded (no `store` ability)
2. **One Profile Per User**: Enforced via ProfileRegistry tracking with Table
3. **Owner-Only Updates**: Only profile owner can update profile, add/edit projects, mint certificates
4. **Certificate Tradeability**: Certificates can be traded but are linked to original profile
5. **Admin Verification**: Admin can verify trusted profiles (verify_profile function)
6. **Error Handling**: Clear error codes for debugging and user feedback

## 📦 Frontend Integration Example

```typescript
// Check if user can mint
const canMint = !(await hasUserMinted(walletAddress));

// Mint profile
if (canMint) {
  await mintProfile({
    name: "Alice",
    bio: "Web3 Developer",
    avatarUrl: walrusAvatarUrl,
    bannerUrl: walrusBannerUrl,
    socialLinks: ["twitter:alice", "github:alice"],
  });
}

// Add project
await addProject({
  profileId: userProfileNftId,
  name: "DeFi Protocol",
  linkDemo: "https://mydefi.app",
  description: "Decentralized lending",
  tags: ["DeFi", "Sui", "Lending"],
});

// List all projects
for (let i = 0; i < projectCount; i++) {
  const project = await getProject(profileId, i);
  console.log(project.name, project.link_demo);
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License

## 🔗 Links

- **Sui Docs**: https://docs.sui.io
- **Walrus**: https://docs.walrus.site
- **Suiscan**: https://suiscan.xyz

---

Built with ❤️ on Sui blockchain
