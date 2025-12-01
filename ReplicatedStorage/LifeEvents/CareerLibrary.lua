-- CareerLibrary.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- GODLY CAREER DEFINITIONS - 50+ Career Paths with Tiers & Branches
-- ═══════════════════════════════════════════════════════════════════════════════
-- 
-- Each career has:
-- - id: unique identifier
-- - label: display name
-- - category: grouping (tech, medical, crime, creative, etc.)
-- - entryEventId: first event that starts this career
-- - tiers: progression ladder with income ranges and event tags
-- - branches: optional split paths (ethical vs unethical, etc.)
--
-- ROBLOX TOS COMPLIANT - No real hacking, no explicit crime details
-- ═══════════════════════════════════════════════════════════════════════════════

local CareerLibrary = {}

-- ═══════════════════════════════════════════════════════════════
-- TECHNOLOGY CAREERS
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["software_developer"] = {
	id = "software_developer",
	label = "Software Developer",
	emoji = "💻",
	category = "tech",
	entryEventId = "tech_first_coding_project",
	tiers = {
		{ id = "junior_dev", label = "Junior Developer", minAge = 18, baseIncome = {min = 55000, max = 75000}, eventTags = {"tech_junior", "coding"} },
		{ id = "mid_dev", label = "Software Developer", minAge = 21, baseIncome = {min = 80000, max = 120000}, eventTags = {"tech_mid", "coding"} },
		{ id = "senior_dev", label = "Senior Developer", minAge = 25, baseIncome = {min = 120000, max = 180000}, eventTags = {"tech_senior", "architecture"} },
		{ id = "staff_dev", label = "Staff Engineer", minAge = 28, baseIncome = {min = 180000, max = 280000}, eventTags = {"tech_staff", "leadership"} },
		{ id = "principal", label = "Principal Engineer", minAge = 32, baseIncome = {min = 250000, max = 400000}, eventTags = {"tech_principal", "vision"} },
	},
}

CareerLibrary["cybersecurity"] = {
	id = "cybersecurity",
	label = "Cybersecurity Professional",
	emoji = "🛡️",
	category = "tech",
	entryEventId = "security_interest_sparked",
	branches = {"ethical", "gray_hat"},
	tiers = {
		{ id = "security_intern", label = "Security Intern", minAge = 18, baseIncome = {min = 45000, max = 60000}, eventTags = {"security_basics"}, branch = nil },
		-- Ethical path
		{ id = "security_analyst", label = "Security Analyst", minAge = 20, baseIncome = {min = 70000, max = 100000}, eventTags = {"security_analyst", "bug_bounty"}, branch = "ethical" },
		{ id = "pentester", label = "Penetration Tester", minAge = 23, baseIncome = {min = 100000, max = 150000}, eventTags = {"pentester", "ethical_hacking"}, branch = "ethical" },
		{ id = "security_lead", label = "Security Lead", minAge = 27, baseIncome = {min = 150000, max = 220000}, eventTags = {"security_lead", "team_management"}, branch = "ethical" },
		{ id = "ciso", label = "Chief Security Officer", minAge = 32, baseIncome = {min = 200000, max = 350000}, eventTags = {"ciso", "executive"}, branch = "ethical" },
		-- Gray hat path (morally ambiguous but not illegal)
		{ id = "freelance_researcher", label = "Freelance Researcher", minAge = 20, baseIncome = {min = 50000, max = 200000}, eventTags = {"gray_hat", "bounty_hunter"}, branch = "gray_hat" },
		{ id = "exploit_researcher", label = "Exploit Researcher", minAge = 24, baseIncome = {min = 100000, max = 300000}, eventTags = {"zero_day", "research"}, branch = "gray_hat" },
	},
}

CareerLibrary["game_developer"] = {
	id = "game_developer",
	label = "Game Developer",
	emoji = "🎮",
	category = "tech",
	entryEventId = "first_game_project",
	tiers = {
		{ id = "hobbyist", label = "Hobbyist Developer", minAge = 13, baseIncome = {min = 0, max = 5000}, eventTags = {"game_dev_hobby"} },
		{ id = "indie_dev", label = "Indie Developer", minAge = 16, baseIncome = {min = 10000, max = 50000}, eventTags = {"indie_game"} },
		{ id = "junior_game_dev", label = "Junior Game Dev", minAge = 18, baseIncome = {min = 50000, max = 70000}, eventTags = {"game_studio_junior"} },
		{ id = "game_programmer", label = "Game Programmer", minAge = 22, baseIncome = {min = 80000, max = 130000}, eventTags = {"game_programming"} },
		{ id = "lead_dev", label = "Lead Developer", minAge = 26, baseIncome = {min = 120000, max = 180000}, eventTags = {"game_lead"} },
		{ id = "studio_founder", label = "Studio Founder", minAge = 25, baseIncome = {min = 0, max = 500000}, eventTags = {"game_studio_owner"} },
	},
}

CareerLibrary["data_scientist"] = {
	id = "data_scientist",
	label = "Data Scientist",
	emoji = "📊",
	category = "tech",
	entryEventId = "data_analysis_discovery",
	tiers = {
		{ id = "data_analyst", label = "Data Analyst", minAge = 20, baseIncome = {min = 55000, max = 75000}, eventTags = {"data_basics"} },
		{ id = "data_scientist_jr", label = "Junior Data Scientist", minAge = 22, baseIncome = {min = 80000, max = 110000}, eventTags = {"ml_basics"} },
		{ id = "data_scientist_sr", label = "Senior Data Scientist", minAge = 26, baseIncome = {min = 130000, max = 180000}, eventTags = {"ml_advanced"} },
		{ id = "ml_engineer", label = "ML Engineer", minAge = 28, baseIncome = {min = 160000, max = 250000}, eventTags = {"ml_engineering"} },
		{ id = "ai_research", label = "AI Researcher", minAge = 28, baseIncome = {min = 180000, max = 350000}, eventTags = {"ai_research"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- MEDICAL CAREERS
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["doctor"] = {
	id = "doctor",
	label = "Doctor",
	emoji = "👨‍⚕️",
	category = "medical",
	entryEventId = "medical_school_accepted",
	requiresEducation = "bachelor",
	tiers = {
		{ id = "med_student", label = "Medical Student", minAge = 22, baseIncome = {min = 0, max = 0}, eventTags = {"med_school"} },
		{ id = "resident", label = "Resident", minAge = 26, baseIncome = {min = 55000, max = 70000}, eventTags = {"residency"} },
		{ id = "attending", label = "Attending Physician", minAge = 30, baseIncome = {min = 200000, max = 300000}, eventTags = {"attending_doctor"} },
		{ id = "specialist", label = "Specialist", minAge = 33, baseIncome = {min = 300000, max = 500000}, eventTags = {"medical_specialist"} },
		{ id = "department_head", label = "Department Head", minAge = 40, baseIncome = {min = 400000, max = 700000}, eventTags = {"medical_leadership"} },
	},
}

CareerLibrary["nurse"] = {
	id = "nurse",
	label = "Nurse",
	emoji = "👩‍⚕️",
	category = "medical",
	entryEventId = "nursing_school_start",
	tiers = {
		{ id = "nursing_student", label = "Nursing Student", minAge = 18, baseIncome = {min = 0, max = 0}, eventTags = {"nursing_school"} },
		{ id = "rn", label = "Registered Nurse", minAge = 22, baseIncome = {min = 60000, max = 80000}, eventTags = {"hospital_nurse"} },
		{ id = "senior_nurse", label = "Senior Nurse", minAge = 26, baseIncome = {min = 75000, max = 100000}, eventTags = {"senior_nursing"} },
		{ id = "nurse_practitioner", label = "Nurse Practitioner", minAge = 28, baseIncome = {min = 100000, max = 130000}, eventTags = {"np_practice"} },
		{ id = "charge_nurse", label = "Charge Nurse", minAge = 30, baseIncome = {min = 90000, max = 120000}, eventTags = {"nursing_leadership"} },
	},
}

CareerLibrary["surgeon"] = {
	id = "surgeon",
	label = "Surgeon",
	emoji = "🏥",
	category = "medical",
	entryEventId = "surgery_residency_match",
	requiresEducation = "medical",
	tiers = {
		{ id = "surgery_resident", label = "Surgery Resident", minAge = 26, baseIncome = {min = 60000, max = 75000}, eventTags = {"surgery_training"} },
		{ id = "fellow", label = "Surgical Fellow", minAge = 31, baseIncome = {min = 80000, max = 100000}, eventTags = {"surgical_fellowship"} },
		{ id = "attending_surgeon", label = "Attending Surgeon", minAge = 33, baseIncome = {min = 350000, max = 500000}, eventTags = {"surgeon_attending"} },
		{ id = "chief_surgeon", label = "Chief of Surgery", minAge = 45, baseIncome = {min = 500000, max = 800000}, eventTags = {"surgery_chief"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- LEGAL CAREERS
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["lawyer"] = {
	id = "lawyer",
	label = "Lawyer",
	emoji = "⚖️",
	category = "legal",
	entryEventId = "law_school_accepted",
	requiresEducation = "bachelor",
	branches = {"corporate", "criminal_defense", "public_interest"},
	tiers = {
		{ id = "law_student", label = "Law Student", minAge = 22, baseIncome = {min = 0, max = 0}, eventTags = {"law_school"}, branch = nil },
		{ id = "associate", label = "Associate", minAge = 25, baseIncome = {min = 80000, max = 190000}, eventTags = {"junior_lawyer"}, branch = nil },
		-- Corporate path
		{ id = "corporate_associate", label = "Corporate Associate", minAge = 27, baseIncome = {min = 150000, max = 250000}, eventTags = {"corporate_law"}, branch = "corporate" },
		{ id = "partner", label = "Partner", minAge = 33, baseIncome = {min = 300000, max = 1000000}, eventTags = {"law_partner"}, branch = "corporate" },
		-- Criminal defense
		{ id = "defense_attorney", label = "Defense Attorney", minAge = 27, baseIncome = {min = 80000, max = 200000}, eventTags = {"criminal_defense"}, branch = "criminal_defense" },
		{ id = "top_defense", label = "Top Defense Lawyer", minAge = 35, baseIncome = {min = 200000, max = 500000}, eventTags = {"famous_lawyer"}, branch = "criminal_defense" },
		-- Public interest
		{ id = "public_defender", label = "Public Defender", minAge = 26, baseIncome = {min = 55000, max = 80000}, eventTags = {"public_defender"}, branch = "public_interest" },
		{ id = "civil_rights", label = "Civil Rights Lawyer", minAge = 30, baseIncome = {min = 70000, max = 150000}, eventTags = {"civil_rights_law"}, branch = "public_interest" },
	},
}

CareerLibrary["judge"] = {
	id = "judge",
	label = "Judge",
	emoji = "🧑‍⚖️",
	category = "legal",
	entryEventId = "judicial_appointment",
	requiresEducation = "law",
	tiers = {
		{ id = "magistrate", label = "Magistrate", minAge = 35, baseIncome = {min = 120000, max = 150000}, eventTags = {"magistrate"} },
		{ id = "district_judge", label = "District Judge", minAge = 40, baseIncome = {min = 170000, max = 220000}, eventTags = {"district_court"} },
		{ id = "appellate_judge", label = "Appellate Judge", minAge = 50, baseIncome = {min = 220000, max = 280000}, eventTags = {"appeals_court"} },
		{ id = "supreme_court", label = "Supreme Court Justice", minAge = 55, baseIncome = {min = 280000, max = 300000}, eventTags = {"supreme_court"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- BUSINESS CAREERS
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["entrepreneur"] = {
	id = "entrepreneur",
	label = "Entrepreneur",
	emoji = "🚀",
	category = "business",
	entryEventId = "business_idea_spark",
	tiers = {
		{ id = "side_hustler", label = "Side Hustler", minAge = 16, baseIncome = {min = 0, max = 20000}, eventTags = {"side_business"} },
		{ id = "startup_founder", label = "Startup Founder", minAge = 18, baseIncome = {min = 0, max = 100000}, eventTags = {"startup_life"} },
		{ id = "small_biz_owner", label = "Small Business Owner", minAge = 21, baseIncome = {min = 50000, max = 200000}, eventTags = {"small_business"} },
		{ id = "successful_founder", label = "Successful Founder", minAge = 25, baseIncome = {min = 200000, max = 1000000}, eventTags = {"scaling_business"} },
		{ id = "serial_entrepreneur", label = "Serial Entrepreneur", minAge = 30, baseIncome = {min = 500000, max = 5000000}, eventTags = {"serial_founder"} },
		{ id = "mogul", label = "Business Mogul", minAge = 40, baseIncome = {min = 1000000, max = 50000000}, eventTags = {"mogul", "billionaire"} },
	},
}

CareerLibrary["finance"] = {
	id = "finance",
	label = "Finance Professional",
	emoji = "💹",
	category = "business",
	entryEventId = "finance_internship",
	branches = {"banking", "trading", "wealth_management"},
	tiers = {
		{ id = "analyst", label = "Financial Analyst", minAge = 22, baseIncome = {min = 70000, max = 100000}, eventTags = {"finance_basics"}, branch = nil },
		-- Banking
		{ id = "investment_banker", label = "Investment Banker", minAge = 24, baseIncome = {min = 150000, max = 300000}, eventTags = {"investment_banking"}, branch = "banking" },
		{ id = "vp_banking", label = "VP of Banking", minAge = 30, baseIncome = {min = 300000, max = 600000}, eventTags = {"banking_leadership"}, branch = "banking" },
		{ id = "md_banking", label = "Managing Director", minAge = 35, baseIncome = {min = 500000, max = 2000000}, eventTags = {"banking_md"}, branch = "banking" },
		-- Trading
		{ id = "trader", label = "Trader", minAge = 24, baseIncome = {min = 100000, max = 500000}, eventTags = {"trading_floor"}, branch = "trading" },
		{ id = "head_trader", label = "Head Trader", minAge = 32, baseIncome = {min = 500000, max = 2000000}, eventTags = {"trading_boss"}, branch = "trading" },
		-- Wealth management
		{ id = "financial_advisor", label = "Financial Advisor", minAge = 24, baseIncome = {min = 60000, max = 150000}, eventTags = {"wealth_advisor"}, branch = "wealth_management" },
		{ id = "wealth_manager", label = "Wealth Manager", minAge = 30, baseIncome = {min = 150000, max = 500000}, eventTags = {"wealth_management"}, branch = "wealth_management" },
	},
}

CareerLibrary["real_estate"] = {
	id = "real_estate",
	label = "Real Estate",
	emoji = "🏠",
	category = "business",
	entryEventId = "real_estate_license",
	tiers = {
		{ id = "agent", label = "Real Estate Agent", minAge = 18, baseIncome = {min = 30000, max = 80000}, eventTags = {"real_estate_agent"} },
		{ id = "broker", label = "Real Estate Broker", minAge = 25, baseIncome = {min = 80000, max = 200000}, eventTags = {"real_estate_broker"} },
		{ id = "investor", label = "Real Estate Investor", minAge = 28, baseIncome = {min = 100000, max = 500000}, eventTags = {"property_investor"} },
		{ id = "developer", label = "Real Estate Developer", minAge = 35, baseIncome = {min = 300000, max = 2000000}, eventTags = {"property_developer"} },
		{ id = "magnate", label = "Real Estate Magnate", minAge = 45, baseIncome = {min = 1000000, max = 10000000}, eventTags = {"real_estate_mogul"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- CREATIVE CAREERS
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["musician"] = {
	id = "musician",
	label = "Musician",
	emoji = "🎵",
	category = "creative",
	entryEventId = "music_first_performance",
	branches = {"solo", "band"},
	tiers = {
		{ id = "bedroom_artist", label = "Bedroom Artist", minAge = 13, baseIncome = {min = 0, max = 1000}, eventTags = {"music_hobby"}, branch = nil },
		{ id = "local_performer", label = "Local Performer", minAge = 16, baseIncome = {min = 5000, max = 20000}, eventTags = {"local_gigs"}, branch = nil },
		{ id = "indie_artist", label = "Indie Artist", minAge = 18, baseIncome = {min = 20000, max = 80000}, eventTags = {"indie_music"}, branch = nil },
		{ id = "signed_artist", label = "Signed Artist", minAge = 18, baseIncome = {min = 50000, max = 300000}, eventTags = {"record_deal"}, branch = nil },
		{ id = "mainstream", label = "Mainstream Artist", minAge = 20, baseIncome = {min = 200000, max = 2000000}, eventTags = {"mainstream_music"}, branch = nil },
		{ id = "superstar", label = "Music Superstar", minAge = 20, baseIncome = {min = 1000000, max = 50000000}, eventTags = {"music_fame", "celebrity"}, branch = nil },
	},
}

CareerLibrary["actor"] = {
	id = "actor",
	label = "Actor",
	emoji = "🎭",
	category = "creative",
	entryEventId = "acting_first_role",
	tiers = {
		{ id = "extra", label = "Background Extra", minAge = 16, baseIncome = {min = 5000, max = 20000}, eventTags = {"acting_extra"} },
		{ id = "theater", label = "Theater Actor", minAge = 18, baseIncome = {min = 20000, max = 50000}, eventTags = {"theater"} },
		{ id = "supporting", label = "Supporting Actor", minAge = 20, baseIncome = {min = 50000, max = 150000}, eventTags = {"supporting_role"} },
		{ id = "lead", label = "Lead Actor", minAge = 22, baseIncome = {min = 150000, max = 500000}, eventTags = {"lead_role"} },
		{ id = "movie_star", label = "Movie Star", minAge = 25, baseIncome = {min = 1000000, max = 20000000}, eventTags = {"movie_star", "celebrity"} },
		{ id = "a_list", label = "A-List Celebrity", minAge = 28, baseIncome = {min = 5000000, max = 50000000}, eventTags = {"a_list", "icon"} },
	},
}

CareerLibrary["writer"] = {
	id = "writer",
	label = "Writer",
	emoji = "✍️",
	category = "creative",
	entryEventId = "writing_first_story",
	branches = {"novelist", "screenwriter", "journalist"},
	tiers = {
		{ id = "aspiring", label = "Aspiring Writer", minAge = 16, baseIncome = {min = 0, max = 5000}, eventTags = {"writing_hobby"}, branch = nil },
		{ id = "freelance_writer", label = "Freelance Writer", minAge = 18, baseIncome = {min = 20000, max = 50000}, eventTags = {"freelance_writing"}, branch = nil },
		-- Novelist
		{ id = "published_author", label = "Published Author", minAge = 22, baseIncome = {min = 30000, max = 100000}, eventTags = {"published_book"}, branch = "novelist" },
		{ id = "bestseller", label = "Bestselling Author", minAge = 25, baseIncome = {min = 100000, max = 1000000}, eventTags = {"bestseller"}, branch = "novelist" },
		-- Screenwriter
		{ id = "staff_writer", label = "Staff Writer", minAge = 24, baseIncome = {min = 60000, max = 150000}, eventTags = {"tv_writing"}, branch = "screenwriter" },
		{ id = "showrunner", label = "Showrunner", minAge = 32, baseIncome = {min = 200000, max = 2000000}, eventTags = {"showrunner"}, branch = "screenwriter" },
		-- Journalist
		{ id = "reporter", label = "Reporter", minAge = 22, baseIncome = {min = 35000, max = 60000}, eventTags = {"journalism"}, branch = "journalist" },
		{ id = "senior_journalist", label = "Senior Journalist", minAge = 30, baseIncome = {min = 80000, max = 150000}, eventTags = {"investigative"}, branch = "journalist" },
	},
}

CareerLibrary["artist"] = {
	id = "artist",
	label = "Visual Artist",
	emoji = "🎨",
	category = "creative",
	entryEventId = "art_first_exhibition",
	tiers = {
		{ id = "hobbyist_artist", label = "Hobbyist Artist", minAge = 13, baseIncome = {min = 0, max = 2000}, eventTags = {"art_hobby"} },
		{ id = "freelance_artist", label = "Freelance Artist", minAge = 18, baseIncome = {min = 20000, max = 50000}, eventTags = {"freelance_art"} },
		{ id = "exhibited", label = "Exhibited Artist", minAge = 22, baseIncome = {min = 30000, max = 100000}, eventTags = {"gallery_show"} },
		{ id = "established", label = "Established Artist", minAge = 28, baseIncome = {min = 80000, max = 300000}, eventTags = {"art_commissions"} },
		{ id = "renowned", label = "Renowned Artist", minAge = 35, baseIncome = {min = 200000, max = 2000000}, eventTags = {"famous_artist"} },
	},
}

CareerLibrary["influencer"] = {
	id = "influencer",
	label = "Social Media Influencer",
	emoji = "📱",
	category = "creative",
	entryEventId = "social_media_viral",
	tiers = {
		{ id = "micro", label = "Micro Influencer", minAge = 13, baseIncome = {min = 0, max = 5000}, eventTags = {"small_following"} },
		{ id = "growing", label = "Growing Creator", minAge = 15, baseIncome = {min = 5000, max = 30000}, eventTags = {"content_growth"} },
		{ id = "established_creator", label = "Established Creator", minAge = 17, baseIncome = {min = 30000, max = 100000}, eventTags = {"brand_deals"} },
		{ id = "popular", label = "Popular Influencer", minAge = 18, baseIncome = {min = 100000, max = 500000}, eventTags = {"influencer_fame"} },
		{ id = "mega", label = "Mega Influencer", minAge = 19, baseIncome = {min = 500000, max = 5000000}, eventTags = {"mega_influencer", "celebrity"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- SPORTS CAREERS
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["athlete"] = {
	id = "athlete",
	label = "Professional Athlete",
	emoji = "🏆",
	category = "sports",
	entryEventId = "sports_scholarship_offer",
	branches = {"basketball", "football", "soccer", "baseball", "tennis"},
	tiers = {
		{ id = "youth_athlete", label = "Youth Athlete", minAge = 10, baseIncome = {min = 0, max = 0}, eventTags = {"youth_sports"}, branch = nil },
		{ id = "high_school", label = "High School Star", minAge = 14, baseIncome = {min = 0, max = 0}, eventTags = {"hs_sports"}, branch = nil },
		{ id = "college", label = "College Athlete", minAge = 18, baseIncome = {min = 0, max = 50000}, eventTags = {"college_sports"}, branch = nil },
		{ id = "minor_league", label = "Minor League", minAge = 20, baseIncome = {min = 30000, max = 100000}, eventTags = {"minor_league"}, branch = nil },
		{ id = "professional", label = "Professional", minAge = 21, baseIncome = {min = 500000, max = 5000000}, eventTags = {"pro_sports"}, branch = nil },
		{ id = "all_star", label = "All-Star", minAge = 23, baseIncome = {min = 5000000, max = 30000000}, eventTags = {"all_star"}, branch = nil },
		{ id = "legend", label = "Sports Legend", minAge = 28, baseIncome = {min = 20000000, max = 100000000}, eventTags = {"sports_legend", "hall_of_fame"}, branch = nil },
	},
}

CareerLibrary["coach"] = {
	id = "coach",
	label = "Sports Coach",
	emoji = "📋",
	category = "sports",
	entryEventId = "coaching_opportunity",
	tiers = {
		{ id = "youth_coach", label = "Youth Coach", minAge = 22, baseIncome = {min = 20000, max = 40000}, eventTags = {"youth_coaching"} },
		{ id = "hs_coach", label = "High School Coach", minAge = 25, baseIncome = {min = 40000, max = 70000}, eventTags = {"hs_coaching"} },
		{ id = "college_coach", label = "College Coach", minAge = 30, baseIncome = {min = 100000, max = 500000}, eventTags = {"college_coaching"} },
		{ id = "pro_coach", label = "Professional Coach", minAge = 35, baseIncome = {min = 500000, max = 5000000}, eventTags = {"pro_coaching"} },
		{ id = "head_coach", label = "Head Coach", minAge = 40, baseIncome = {min = 2000000, max = 15000000}, eventTags = {"head_coaching"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- MILITARY & LAW ENFORCEMENT
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["military"] = {
	id = "military",
	label = "Military",
	emoji = "🎖️",
	category = "military",
	entryEventId = "military_enlistment",
	branches = {"enlisted", "officer"},
	tiers = {
		-- Enlisted
		{ id = "private", label = "Private", minAge = 18, baseIncome = {min = 25000, max = 35000}, eventTags = {"basic_training"}, branch = "enlisted" },
		{ id = "sergeant", label = "Sergeant", minAge = 22, baseIncome = {min = 40000, max = 55000}, eventTags = {"nco"}, branch = "enlisted" },
		{ id = "staff_sergeant", label = "Staff Sergeant", minAge = 26, baseIncome = {min = 50000, max = 70000}, eventTags = {"senior_nco"}, branch = "enlisted" },
		{ id = "sergeant_major", label = "Sergeant Major", minAge = 35, baseIncome = {min = 70000, max = 90000}, eventTags = {"top_enlisted"}, branch = "enlisted" },
		-- Officer
		{ id = "lieutenant", label = "Lieutenant", minAge = 22, baseIncome = {min = 45000, max = 60000}, eventTags = {"junior_officer"}, branch = "officer" },
		{ id = "captain", label = "Captain", minAge = 26, baseIncome = {min = 60000, max = 85000}, eventTags = {"company_command"}, branch = "officer" },
		{ id = "major", label = "Major", minAge = 32, baseIncome = {min = 80000, max = 110000}, eventTags = {"field_grade"}, branch = "officer" },
		{ id = "colonel", label = "Colonel", minAge = 40, baseIncome = {min = 110000, max = 150000}, eventTags = {"senior_officer"}, branch = "officer" },
		{ id = "general", label = "General", minAge = 50, baseIncome = {min = 150000, max = 200000}, eventTags = {"flag_officer"}, branch = "officer" },
	},
}

CareerLibrary["police"] = {
	id = "police",
	label = "Police Officer",
	emoji = "👮",
	category = "law_enforcement",
	entryEventId = "police_academy",
	tiers = {
		{ id = "cadet", label = "Police Cadet", minAge = 21, baseIncome = {min = 30000, max = 40000}, eventTags = {"police_training"} },
		{ id = "patrol", label = "Patrol Officer", minAge = 22, baseIncome = {min = 45000, max = 65000}, eventTags = {"patrol_duty"} },
		{ id = "detective", label = "Detective", minAge = 26, baseIncome = {min = 60000, max = 85000}, eventTags = {"detective_work"} },
		{ id = "sergeant_police", label = "Sergeant", minAge = 30, baseIncome = {min = 75000, max = 100000}, eventTags = {"police_supervisor"} },
		{ id = "lieutenant_police", label = "Lieutenant", minAge = 35, baseIncome = {min = 90000, max = 120000}, eventTags = {"police_command"} },
		{ id = "captain_police", label = "Captain", minAge = 40, baseIncome = {min = 110000, max = 150000}, eventTags = {"precinct_command"} },
		{ id = "chief", label = "Police Chief", minAge = 50, baseIncome = {min = 150000, max = 250000}, eventTags = {"police_chief"} },
	},
}

CareerLibrary["firefighter"] = {
	id = "firefighter",
	label = "Firefighter",
	emoji = "🚒",
	category = "public_service",
	entryEventId = "fire_academy",
	tiers = {
		{ id = "probie", label = "Probationary Firefighter", minAge = 18, baseIncome = {min = 35000, max = 45000}, eventTags = {"fire_training"} },
		{ id = "firefighter_1", label = "Firefighter", minAge = 20, baseIncome = {min = 45000, max = 65000}, eventTags = {"firefighting"} },
		{ id = "engineer", label = "Fire Engineer", minAge = 25, baseIncome = {min = 60000, max = 80000}, eventTags = {"fire_engineer"} },
		{ id = "fire_captain", label = "Fire Captain", minAge = 32, baseIncome = {min = 80000, max = 110000}, eventTags = {"fire_captain"} },
		{ id = "battalion_chief", label = "Battalion Chief", minAge = 40, baseIncome = {min = 100000, max = 140000}, eventTags = {"battalion_chief"} },
		{ id = "fire_chief", label = "Fire Chief", minAge = 50, baseIncome = {min = 140000, max = 200000}, eventTags = {"fire_chief"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- EDUCATION CAREERS
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["teacher"] = {
	id = "teacher",
	label = "Teacher",
	emoji = "👨‍🏫",
	category = "education",
	entryEventId = "teaching_credential",
	tiers = {
		{ id = "substitute", label = "Substitute Teacher", minAge = 22, baseIncome = {min = 25000, max = 35000}, eventTags = {"substitute"} },
		{ id = "teacher_entry", label = "Teacher", minAge = 23, baseIncome = {min = 40000, max = 55000}, eventTags = {"classroom_teaching"} },
		{ id = "senior_teacher", label = "Senior Teacher", minAge = 28, baseIncome = {min = 55000, max = 75000}, eventTags = {"experienced_teacher"} },
		{ id = "department_head_edu", label = "Department Head", minAge = 35, baseIncome = {min = 70000, max = 90000}, eventTags = {"department_head"} },
		{ id = "assistant_principal", label = "Assistant Principal", minAge = 38, baseIncome = {min = 80000, max = 110000}, eventTags = {"school_admin"} },
		{ id = "principal", label = "Principal", minAge = 42, baseIncome = {min = 100000, max = 150000}, eventTags = {"principal"} },
		{ id = "superintendent", label = "Superintendent", minAge = 50, baseIncome = {min = 150000, max = 250000}, eventTags = {"superintendent"} },
	},
}

CareerLibrary["professor"] = {
	id = "professor",
	label = "Professor",
	emoji = "🎓",
	category = "education",
	entryEventId = "phd_program_start",
	requiresEducation = "phd",
	tiers = {
		{ id = "grad_student", label = "Graduate Student", minAge = 22, baseIncome = {min = 20000, max = 35000}, eventTags = {"grad_school"} },
		{ id = "postdoc", label = "Postdoctoral Researcher", minAge = 28, baseIncome = {min = 50000, max = 70000}, eventTags = {"postdoc"} },
		{ id = "assistant_prof", label = "Assistant Professor", minAge = 30, baseIncome = {min = 70000, max = 100000}, eventTags = {"assistant_professor"} },
		{ id = "associate_prof", label = "Associate Professor", minAge = 36, baseIncome = {min = 90000, max = 130000}, eventTags = {"associate_professor"} },
		{ id = "full_prof", label = "Full Professor", minAge = 42, baseIncome = {min = 120000, max = 200000}, eventTags = {"full_professor"} },
		{ id = "distinguished", label = "Distinguished Professor", minAge = 55, baseIncome = {min = 180000, max = 350000}, eventTags = {"distinguished"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- CRIMINAL CAREERS (Roblox TOS Compliant - Cartoonish/Generic)
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["street_hustler"] = {
	id = "street_hustler",
	label = "Street Hustler",
	emoji = "🎲",
	category = "criminal",
	entryEventId = "hustle_opportunity",
	tiers = {
		{ id = "small_time", label = "Small-Time Hustler", minAge = 16, baseIncome = {min = 5000, max = 20000}, eventTags = {"petty_crime"} },
		{ id = "street_smart", label = "Street Smart", minAge = 18, baseIncome = {min = 20000, max = 50000}, eventTags = {"street_life"} },
		{ id = "crew_member", label = "Crew Member", minAge = 20, baseIncome = {min = 40000, max = 100000}, eventTags = {"gang_life"} },
		{ id = "crew_leader", label = "Crew Leader", minAge = 24, baseIncome = {min = 100000, max = 300000}, eventTags = {"gang_leader"} },
		{ id = "boss", label = "Crime Boss", minAge = 30, baseIncome = {min = 300000, max = 1000000}, eventTags = {"crime_boss"} },
	},
}

CareerLibrary["con_artist"] = {
	id = "con_artist",
	label = "Con Artist",
	emoji = "🎭",
	category = "criminal",
	entryEventId = "first_con",
	tiers = {
		{ id = "small_scams", label = "Small-Time Scammer", minAge = 18, baseIncome = {min = 10000, max = 30000}, eventTags = {"small_cons"} },
		{ id = "grifter", label = "Grifter", minAge = 22, baseIncome = {min = 30000, max = 100000}, eventTags = {"grifting"} },
		{ id = "professional_con", label = "Professional Con Artist", minAge = 26, baseIncome = {min = 100000, max = 500000}, eventTags = {"long_con"} },
		{ id = "mastermind", label = "Con Mastermind", minAge = 32, baseIncome = {min = 500000, max = 2000000}, eventTags = {"mastermind"} },
	},
}

CareerLibrary["car_thief"] = {
	id = "car_thief",
	label = "Car Thief",
	emoji = "🚗",
	category = "criminal",
	entryEventId = "first_car_boost",
	tiers = {
		{ id = "joyride", label = "Joyrider", minAge = 16, baseIncome = {min = 0, max = 5000}, eventTags = {"joyriding"} },
		{ id = "boost_crew", label = "Boost Crew Member", minAge = 18, baseIncome = {min = 20000, max = 50000}, eventTags = {"car_theft_basic"} },
		{ id = "professional_thief", label = "Professional Thief", minAge = 21, baseIncome = {min = 50000, max = 150000}, eventTags = {"car_theft_pro"} },
		{ id = "ring_leader", label = "Ring Leader", minAge = 26, baseIncome = {min = 150000, max = 500000}, eventTags = {"car_ring"} },
	},
}

CareerLibrary["burglar"] = {
	id = "burglar",
	label = "Burglar",
	emoji = "🏠",
	category = "criminal",
	entryEventId = "first_break_in",
	tiers = {
		{ id = "petty_thief", label = "Petty Thief", minAge = 16, baseIncome = {min = 5000, max = 15000}, eventTags = {"petty_theft"} },
		{ id = "house_burglar", label = "House Burglar", minAge = 18, baseIncome = {min = 20000, max = 60000}, eventTags = {"burglary_basic"} },
		{ id = "cat_burglar", label = "Cat Burglar", minAge = 22, baseIncome = {min = 60000, max = 200000}, eventTags = {"cat_burglar"} },
		{ id = "master_thief", label = "Master Thief", minAge = 28, baseIncome = {min = 200000, max = 1000000}, eventTags = {"master_thief"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- POLITICS & GOVERNMENT
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["politician"] = {
	id = "politician",
	label = "Politician",
	emoji = "🏛️",
	category = "government",
	entryEventId = "political_campaign_start",
	tiers = {
		{ id = "activist", label = "Political Activist", minAge = 18, baseIncome = {min = 0, max = 30000}, eventTags = {"activism"} },
		{ id = "local_council", label = "City Council Member", minAge = 25, baseIncome = {min = 40000, max = 80000}, eventTags = {"local_politics"} },
		{ id = "mayor", label = "Mayor", minAge = 30, baseIncome = {min = 80000, max = 200000}, eventTags = {"mayor"} },
		{ id = "state_rep", label = "State Representative", minAge = 28, baseIncome = {min = 60000, max = 120000}, eventTags = {"state_politics"} },
		{ id = "senator", label = "Senator", minAge = 35, baseIncome = {min = 175000, max = 200000}, eventTags = {"senator"} },
		{ id = "governor", label = "Governor", minAge = 35, baseIncome = {min = 150000, max = 250000}, eventTags = {"governor"} },
		{ id = "president", label = "President", minAge = 35, baseIncome = {min = 400000, max = 500000}, eventTags = {"president", "world_leader"} },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- SCIENCE & RESEARCH
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["scientist"] = {
	id = "scientist",
	label = "Scientist",
	emoji = "🔬",
	category = "science",
	entryEventId = "research_passion",
	branches = {"biology", "chemistry", "physics", "astronomy"},
	tiers = {
		{ id = "research_assistant", label = "Research Assistant", minAge = 20, baseIncome = {min = 30000, max = 45000}, eventTags = {"lab_work"}, branch = nil },
		{ id = "phd_candidate", label = "PhD Candidate", minAge = 22, baseIncome = {min = 25000, max = 40000}, eventTags = {"phd_research"}, branch = nil },
		{ id = "research_scientist", label = "Research Scientist", minAge = 28, baseIncome = {min = 70000, max = 100000}, eventTags = {"research"}, branch = nil },
		{ id = "senior_scientist", label = "Senior Scientist", minAge = 35, baseIncome = {min = 100000, max = 150000}, eventTags = {"senior_research"}, branch = nil },
		{ id = "lab_director", label = "Lab Director", minAge = 45, baseIncome = {min = 150000, max = 250000}, eventTags = {"lab_director"}, branch = nil },
		{ id = "nobel_laureate", label = "Nobel Laureate", minAge = 50, baseIncome = {min = 200000, max = 500000}, eventTags = {"nobel_prize"}, branch = nil },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- PILOT / AVIATION
-- ═══════════════════════════════════════════════════════════════

CareerLibrary["pilot"] = {
	id = "pilot",
	label = "Pilot",
	emoji = "✈️",
	category = "aviation",
	entryEventId = "flight_school_start",
	branches = {"commercial", "military_aviation"},
	tiers = {
		{ id = "student_pilot", label = "Student Pilot", minAge = 17, baseIncome = {min = 0, max = 0}, eventTags = {"flight_training"}, branch = nil },
		{ id = "private_pilot", label = "Private Pilot", minAge = 18, baseIncome = {min = 0, max = 20000}, eventTags = {"private_flying"}, branch = nil },
		-- Commercial
		{ id = "regional_pilot", label = "Regional Pilot", minAge = 21, baseIncome = {min = 50000, max = 80000}, eventTags = {"regional_airline"}, branch = "commercial" },
		{ id = "first_officer", label = "First Officer", minAge = 25, baseIncome = {min = 80000, max = 150000}, eventTags = {"first_officer"}, branch = "commercial" },
		{ id = "airline_captain", label = "Airline Captain", minAge = 32, baseIncome = {min = 150000, max = 300000}, eventTags = {"airline_captain"}, branch = "commercial" },
		-- Military
		{ id = "military_pilot", label = "Military Pilot", minAge = 22, baseIncome = {min = 60000, max = 90000}, eventTags = {"fighter_pilot"}, branch = "military_aviation" },
		{ id = "squadron_leader", label = "Squadron Leader", minAge = 32, baseIncome = {min = 100000, max = 140000}, eventTags = {"squadron_command"}, branch = "military_aviation" },
	},
}

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

function CareerLibrary.getCareer(careerId)
	return CareerLibrary[careerId]
end

function CareerLibrary.getAllCareers()
	local careers = {}
	for id, career in pairs(CareerLibrary) do
		if type(career) == "table" and career.id then
			table.insert(careers, career)
		end
	end
	return careers
end

function CareerLibrary.getCareersByCategory(category)
	local careers = {}
	for _, career in pairs(CareerLibrary) do
		if type(career) == "table" and career.category == category then
			table.insert(careers, career)
		end
	end
	return careers
end

function CareerLibrary.getTier(careerId, tierIndex)
	local career = CareerLibrary[careerId]
	if career and career.tiers and career.tiers[tierIndex] then
		return career.tiers[tierIndex]
	end
	return nil
end

function CareerLibrary.getTierByBranch(careerId, branch, tierIndex)
	local career = CareerLibrary[careerId]
	if not career or not career.tiers then return nil end
	
	local branchTiers = {}
	for _, tier in ipairs(career.tiers) do
		if tier.branch == nil or tier.branch == branch then
			table.insert(branchTiers, tier)
		end
	end
	
	return branchTiers[tierIndex]
end

return CareerLibrary
