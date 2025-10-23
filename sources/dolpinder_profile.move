module dolpinder_profile::profiles {

    use std::string;
    use sui::tx_context::{sender};
    use sui::event;
    use sui::display;
    use sui::package;
    use sui::table::{Self, Table};
    use sui::dynamic_field as df;

    /// 🧱 NFT Profile - Mỗi user sở hữu 1 NFT profile (không thể trade)
    public struct ProfileNFT has key {
        id: UID,
        owner: address,  // Lưu owner để validate
        name: string::String,
        bio: string::String,
        avatar_url: string::String,   // URL hiển thị trên Suiscan
        banner_url: string::String,
        social_links: vector<string::String>,
        project_count: u64,  // Số lượng projects
        verified: bool,
        created_at: u64,
    }

    /// 🚀 Project struct - Lưu thông tin dự án
    public struct Project has store, drop {
        name: string::String,
        link_demo: string::String,
        description: string::String,
        tags: vector<string::String>,
        created_at: u64,
    }

    /// 📁 Project key để lưu trong dynamic field
    public struct ProjectKey has store, copy, drop {
        index: u64,
    }

    /// 📦 Registry theo dõi tất cả profiles (shared object)
    public struct ProfileRegistry has key {
        id: UID,
        total_profiles: u64,
        minted_users: Table<address, bool>,  // Track users đã mint
    }

    /// 🎫 One-Time-Witness để tạo Display
    public struct PROFILES has drop {}

    /// 🔹 Sự kiện khi profile được tạo
    public struct ProfileCreated has copy, drop {
        profile_id: address,
        owner: address,
        name: string::String,
    }

    /// 🔹 Sự kiện khi profile được cập nhật
    public struct ProfileUpdated has copy, drop {
        profile_id: address,
        owner: address,
    }

    /// 🎯 Init - Tạo Display cho NFT và Registry
    fun init(otw: PROFILES, ctx: &mut sui::tx_context::TxContext) {
        // Tạo Publisher từ OTW
        let publisher = package::claim(otw, ctx);

        // Tạo Display template để NFT hiển thị đẹp trên Suiscan
        let mut display = display::new<ProfileNFT>(&publisher, ctx);
        
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut display, string::utf8(b"description"), string::utf8(b"{bio}"));
        display::add(&mut display, string::utf8(b"image_url"), string::utf8(b"{avatar_url}"));
        display::add(&mut display, string::utf8(b"project_url"), string::utf8(b"https://yourproject.com"));
        display::add(&mut display, string::utf8(b"creator"), string::utf8(b"Dolpinder Profile"));
        
        display::update_version(&mut display);
        
        // Transfer publisher và display cho deployer
        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));

        // Tạo shared registry
        let registry = ProfileRegistry {
            id: object::new(ctx),
            total_profiles: 0,
            minted_users: table::new(ctx),
        };
        transfer::share_object(registry);
    }

    /// 🧍‍♂️ Mint Profile NFT cho user (chỉ được mint 1 lần)
     entry fun mint_profile(
        registry: &mut ProfileRegistry,
        name: string::String,
        bio: string::String,
        avatar_url: string::String,
        banner_url: string::String,
        social_links: vector<string::String>,
        clock: &sui::clock::Clock,
        ctx: &mut sui::tx_context::TxContext
    ) {
        let sender_addr = sender(ctx);
        
        // ⛔ Kiểm tra user đã mint chưa
        assert!(!table::contains(&registry.minted_users, sender_addr), 1); // Error code 1: Already minted
        
        // Đánh dấu user đã mint
        table::add(&mut registry.minted_users, sender_addr, true);
        
        // Tạo NFT Profile
        let profile_nft = ProfileNFT {
            id: object::new(ctx),
            owner: sender_addr,
            name,
            bio,
            avatar_url,
            banner_url,
            social_links,
            project_count: 0,
            verified: false,
            created_at: sui::clock::timestamp_ms(clock),
        };

        let profile_id = object::uid_to_address(&profile_nft.id);

        // Tăng counter
        registry.total_profiles = registry.total_profiles + 1;

        // Emit event
        event::emit(ProfileCreated {
            profile_id,
            owner: sender_addr,
            name: profile_nft.name,
        });

        // Transfer NFT cho user (không thể trade vì không có store ability)
        transfer::transfer(profile_nft, sender_addr);
    }

    /// ✏️ Cập nhật Profile NFT (chỉ owner mới được update)
     entry fun update_profile(
        profile: &mut ProfileNFT,
        name: string::String,
        bio: string::String,
        avatar_url: string::String,
        banner_url: string::String,
        social_links: vector<string::String>,
        ctx: &sui::tx_context::TxContext
    ) {
        let sender_addr = sender(ctx);
        
        // ⛔ Chỉ owner mới được update
        assert!(profile.owner == sender_addr, 2); // Error code 2: Not owner
        
        profile.name = name;
        profile.bio = bio;
        profile.avatar_url = avatar_url;
        profile.banner_url = banner_url;
        profile.social_links = social_links;

        event::emit(ProfileUpdated {
            profile_id: object::uid_to_address(&profile.id),
            owner: sender_addr,
        });
    }

    /// ➕ Thêm project vào profile
    entry fun add_project(
        profile: &mut ProfileNFT,
        name: string::String,
        link_demo: string::String,
        description: string::String,
        tags: vector<string::String>,
        clock: &sui::clock::Clock,
        ctx: &sui::tx_context::TxContext
    ) {
        let sender_addr = sender(ctx);
        assert!(profile.owner == sender_addr, 2); // Chỉ owner mới thêm được
        
        let project = Project {
            name,
            link_demo,
            description,
            tags,
            created_at: sui::clock::timestamp_ms(clock),
        };
        
        // Lưu project vào dynamic field với key là index
        let key = ProjectKey { index: profile.project_count };
        df::add(&mut profile.id, key, project);
        
        // Tăng counter
        profile.project_count = profile.project_count + 1;
    }

    /// ✏️ Sửa project
    entry fun update_project(
        profile: &mut ProfileNFT,
        project_index: u64,
        name: string::String,
        link_demo: string::String,
        description: string::String,
        tags: vector<string::String>,
        clock: &sui::clock::Clock,
        ctx: &sui::tx_context::TxContext
    ) {
        let sender_addr = sender(ctx);
        assert!(profile.owner == sender_addr, 2);
        assert!(project_index < profile.project_count, 3); // Error 3: Invalid project index
        
        let key = ProjectKey { index: project_index };
        
        // Xóa project cũ và thêm mới
        let _old_project: Project = df::remove(&mut profile.id, key);
        
        let new_project = Project {
            name,
            link_demo,
            description,
            tags,
            created_at: sui::clock::timestamp_ms(clock),
        };
        
        df::add(&mut profile.id, key, new_project);
    }

    /// 🗑️ Xóa project
    entry fun remove_project(
        profile: &mut ProfileNFT,
        project_index: u64,
        ctx: &sui::tx_context::TxContext
    ) {
        let sender_addr = sender(ctx);
        assert!(profile.owner == sender_addr, 2);
        assert!(project_index < profile.project_count, 3);
        
        let key = ProjectKey { index: project_index };
        let _project: Project = df::remove(&mut profile.id, key);
        // Project tự động drop
    }

    /// ✅ Xác thực Profile NFT (admin-only, cần thêm AdminCap sau)
    public fun verify_profile(
        profile: &mut ProfileNFT,
        _ctx: &sui::tx_context::TxContext
    ) {
        profile.verified = true;
    }

    // === View Functions cho Profile NFT ===

    /// � Lấy owner address
    public fun owner(profile: &ProfileNFT): address {
        profile.owner
    }

    /// �🖼️ Lấy avatar URL
    public fun avatar_url(profile: &ProfileNFT): string::String {
        profile.avatar_url
    }

    /// 🎨 Lấy banner URL
    public fun banner_url(profile: &ProfileNFT): string::String {
        profile.banner_url
    }

    /// 👤 Lấy tên
    public fun name(profile: &ProfileNFT): string::String {
        profile.name
    }

    /// 📝 Lấy bio
    public fun bio(profile: &ProfileNFT): string::String {
        profile.bio
    }

    /// 🔗 Lấy social links
    public fun social_links(profile: &ProfileNFT): vector<string::String> {
        profile.social_links
    }

    /// ✅ Kiểm tra verified
    public fun is_verified(profile: &ProfileNFT): bool {
        profile.verified
    }

    /// ⏰ Lấy thời gian tạo
    public fun created_at(profile: &ProfileNFT): u64 {
        profile.created_at
    }

    /// 📊 Đếm tổng số profiles đã mint
    public fun total_profiles(registry: &ProfileRegistry): u64 {
        registry.total_profiles
    }

    /// 🔍 Kiểm tra user đã mint profile chưa
    public fun has_minted(registry: &ProfileRegistry, user: address): bool {
        table::contains(&registry.minted_users, user)
    }

    // === View Functions cho Projects ===

    /// 📊 Lấy số lượng projects
    public fun get_project_count(profile: &ProfileNFT): u64 {
        profile.project_count
    }

    /// 🔍 Lấy thông tin 1 project
    public fun get_project(profile: &ProfileNFT, index: u64): &Project {
        let key = ProjectKey { index };
        df::borrow(&profile.id, key)
    }

    /// 🔍 Kiểm tra project có tồn tại không
    public fun project_exists(profile: &ProfileNFT, index: u64): bool {
        let key = ProjectKey { index };
        df::exists_(&profile.id, key)
    }

    /// 🏷️ Lấy tên project
    public fun project_name(project: &Project): string::String {
        project.name
    }

    /// 🔗 Lấy link demo
    public fun project_link(project: &Project): string::String {
        project.link_demo
    }

    /// 📝 Lấy mô tả project
    public fun project_description(project: &Project): string::String {
        project.description
    }

    /// 🏷️ Lấy tags
    public fun project_tags(project: &Project): vector<string::String> {
        project.tags
    }

    /// ⏰ Lấy thời gian tạo project
    public fun project_created_at(project: &Project): u64 {
        project.created_at
    }
}
