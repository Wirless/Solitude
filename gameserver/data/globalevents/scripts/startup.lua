function onStartup()
	db.query("TRUNCATE TABLE `players_online`")
	db.asyncQuery("DELETE FROM `guild_wars` WHERE `status` = 0")
	db.asyncQuery("DELETE FROM `players` WHERE `deletion` != 0 AND `deletion` < " .. os.time())
	db.asyncQuery("DELETE FROM `ip_bans` WHERE `expires_at` != 0 AND `expires_at` <= " .. os.time())

	-- Move expired bans to ban history
	local resultId = db.storeQuery("SELECT * FROM `account_bans` WHERE `expires_at` != 0 AND `expires_at` <= " .. os.time())
	if resultId ~= false then
		repeat
			local accountId = result.getNumber(resultId, "account_id")
			db.asyncQuery("INSERT INTO `account_ban_history` (`account_id`, `reason`, `banned_at`, `expired_at`, `banned_by`) VALUES (" .. accountId .. ", " .. db.escapeString(result.getString(resultId, "reason")) .. ", " .. result.getNumber(resultId, "banned_at") .. ", " .. result.getNumber(resultId, "expires_at") .. ", " .. result.getNumber(resultId, "banned_by") .. ")")
			db.asyncQuery("DELETE FROM `account_bans` WHERE `account_id` = " .. accountId)
		until not result.next(resultId)
		result.free(resultId)
	end

	-- Check house auctions
	local resultId = db.storeQuery("SELECT `id`, `highest_bidder`, `last_bid`, (SELECT `balance` FROM `players` WHERE `players`.`id` = `highest_bidder`) AS `balance`, (SELECT `account_id` FROM `players` WHERE `players`.`id` = `highest_bidder`) AS `account_id` FROM `houses` WHERE `owner` = 0 AND `bid_end` != 0 AND `bid_end` < " .. os.time())
	if resultId ~= false then
		repeat
			local house = House(result.getNumber(resultId, "id"))
			if house then
				local highestBidder = result.getNumber(resultId, "highest_bidder")
				local balance = result.getNumber(resultId, "balance")
				local lastBid = result.getNumber(resultId, "last_bid")

				if configManager.getBoolean(configKeys.HOUSES_BANKSYSTEM) then
					if balance >= lastBid + house:getRent() then
						db.query("UPDATE `players` SET `balance` = " .. (balance - lastBid - house:getRent()) .. " WHERE `id` = " .. highestBidder)
						house:setOwnerGuid(highestBidder)
					end
				else
					if doRemoveOfflinePlayerMoney(highestBidder, house:getTown():getId(), lastBid + house:getRent()) then
						house:setOwnerGuid(highestBidder)
					end
				end
				
				db.asyncQuery("UPDATE `houses` SET `last_bid` = 0, `bid_end` = 0, `highest_bidder` = 0, `bid` = 0 WHERE `id` = " .. house:getId())
				
				-- did not have enough money to pay bid and rent, add a warning to the account
				if house:getOwnerGuid() ~= highestBidder then
					db.query("UPDATE `accounts` SET `failed_bid_count` = `failed_bid_count` + 1 WHERE `id` = " .. result.getNumber("account_id"))
				end
			end
		until not result.next(resultId)
		result.free(resultId)
	end

	-- store towns in database
	db.query("TRUNCATE TABLE `towns`")
	for i, town in ipairs(Game.getTowns()) do
		local position = town:getTemplePosition()
		db.query("INSERT INTO `towns` (`id`, `name`, `posx`, `posy`, `posz`) VALUES (" .. town:getId() .. ", " .. db.escapeString(town:getName()) .. ", " .. position.x .. ", " .. position.y .. ", " .. position.z .. ")")
	end
end
