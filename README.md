# 🎯 Dolpinder Profile - Sui NFT Profile System

A decentralized profile system on Sui blockchain where users can mint their profile as an NFT and manage multiple projects.

## 📋 Features

### ✨ Profile NFT (Soulbound)
- ✅ Each user can mint **ONE** profile NFT
- ✅ Profile cannot be traded (no `store` ability)
- ✅ Display avatar on Suiscan with Display standard
- ✅ Only owner can update their profile
- ✅ Verified badge system

### 🚀 Projects Management
- ✅ Add unlimited projects to your profile using Dynamic Fields
- ✅ Each project includes: name, demo link, description, tags
- ✅ Update/delete projects anytime
- ✅ Gas-efficient storage

## 🏗️ Architecture

```
ProfileRegistry (Shared Object)
  ├─ total_profiles: u64
  └─ minted_users: Table<address, bool>

ProfileNFT (Owned Object - Soulbound)
  ├─ owner: address
  ├─ name, bio, avatar_url, banner_url
  ├─ social_links: vector<String>
  ├─ project_count: u64
  ├─ verified: bool
  └─ Dynamic Fields:
      ├─ Project[0]: {name, link_demo, description, tags, created_at}
      ├─ Project[1]: ...
      └─ Project[n]: ...
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
- **Package ID**: `0x...`
- **Registry ID**: `0x...` (Shared Object)
- **Display ID**: `0x...`

## 📝 Usage

### 1. Mint Profile NFT
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

### 2. Update Profile
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

### 3. Add Project
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

### 4. Update Project
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

### 5. Remove Project
```bash
sui client call \
  --package <PACKAGE_ID> \
  --module profiles \
  --function remove_project \
  --args <PROFILE_NFT_ID> 0 \
  --gas-budget 10000000
```

## 🔍 View Functions

### Check if user has minted
```typescript
const hasMinted = await client.call({
  target: `${packageId}::profiles::has_minted`,
  arguments: [registryId, userAddress]
});
```

### Get profile info
```typescript
const name = await client.call({
  target: `${packageId}::profiles::name`,
  arguments: [profileNftId]
});

const avatarUrl = await client.call({
  target: `${packageId}::profiles::avatar_url`,
  arguments: [profileNftId]
});
```

### Get project info
```typescript
const projectCount = await client.call({
  target: `${packageId}::profiles::get_project_count`,
  arguments: [profileNftId]
});

const project = await client.call({
  target: `${packageId}::profiles::get_project`,
  arguments: [profileNftId, 0] // index 0
});
```

## ⚠️ Error Codes

- **Error 1**: User already minted a profile (cannot mint again)
- **Error 2**: Not the owner (cannot update profile/projects)
- **Error 3**: Invalid project index

## 🛠️ Technology Stack

- **Blockchain**: Sui
- **Language**: Move
- **Storage**: Dynamic Fields for projects
- **Display**: Sui Display Standard
- **Storage**: Walrus (for images)

## 📊 Smart Contract Structure

```move
module dolpinder_profile::profiles {
    // Structs
    public struct ProfileNFT has key { ... }
    public struct ProfileRegistry has key { ... }
    public struct Project has store, drop { ... }
    
    // Entry Functions
    entry fun mint_profile(...)
    entry fun update_profile(...)
    entry fun add_project(...)
    entry fun update_project(...)
    entry fun remove_project(...)
    entry fun verify_profile(...)
    
    // View Functions
    public fun has_minted(...)
    public fun get_project_count(...)
    public fun get_project(...)
    // ... more getters
}
```

## 🎨 Display on Suiscan

Profile NFT will display on Suiscan with:
- **Name**: `{name}`
- **Description**: `{bio}`
- **Image**: `{avatar_url}`
- **Creator**: "Dolpinder Profile"
- **Project URL**: Your custom URL

## 🔐 Security Features

1. **Soulbound Token**: Profile NFT cannot be transferred or traded
2. **One Profile Per User**: Enforced via Registry tracking
3. **Owner-Only Updates**: Only profile owner can update profile/projects
4. **Admin Verification**: Admin can verify trusted builders

## 📦 Frontend Integration Example

```typescript
// Check if user can mint
const canMint = !await hasUserMinted(walletAddress);

// Mint profile
if (canMint) {
  await mintProfile({
    name: "Alice",
    bio: "Web3 Developer",
    avatarUrl: walrusAvatarUrl,
    bannerUrl: walrusBannerUrl,
    socialLinks: ["twitter:alice", "github:alice"]
  });
}

// Add project
await addProject({
  profileId: userProfileNftId,
  name: "DeFi Protocol",
  linkDemo: "https://mydefi.app",
  description: "Decentralized lending",
  tags: ["DeFi", "Sui", "Lending"]
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
