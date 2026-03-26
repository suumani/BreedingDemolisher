-- __BreedingDemolisher__/scripts/core/pet_chart/PetChartJobService.lua
-- ----------------------------
-- Responsibility:
--   Ensure a large area around pet demolishers becomes charted gradually (chunk-by-chunk),
--   to reduce risk of losing entity identity.
--   - Enqueue a chart job at pet placement time.
--   - Process at most N chunks per second, spiraling from center outward.
-- Notes:
--   - 1280x1280 area => radius_tiles=640 => max_ring=ceil(640/32)=20 (approx 40x40 chunks).
--   - This service does NOT attempt to "keep charted forever"; it finishes once per job.
--   - storage.bd_pet_chart_jobs is bootstrap-managed and must already exist.
-- ----------------------------

local S = {}

local CHUNK_SIZE = 32

local function expect_storage()
  if storage == nil then
    error("PetChartJobService: storage is nil")
  end
  if storage.bd_pet_chart_jobs == nil then
    error("PetChartJobService: storage.bd_pet_chart_jobs is nil. Call StorageBootstrap.bootstrap() first.")
  end
end

local function chunk_xy_from_pos(pos)
  return math.floor(pos.x / CHUNK_SIZE), math.floor(pos.y / CHUNK_SIZE)
end

local function chart_chunk(force, surface, cx, cy)
  local area = {
    left_top = { x = cx * CHUNK_SIZE, y = cy * CHUNK_SIZE },
    right_bottom = { x = (cx + 1) * CHUNK_SIZE, y = (cy + 1) * CHUNK_SIZE },
  }
  force.chart(surface, area)
end

local function ring_point(r, i)
  if r == 0 then return 0, 0 end
  local len = 8 * r
  i = i % len

  if i < 2 * r then
    return -r + i, -r
  end
  i = i - 2 * r

  if i < 2 * r then
    return r, -r + i
  end
  i = i - 2 * r

  if i < 2 * r then
    return r - i, r
  end
  i = i - 2 * r

  return -r, r - i
end

local function is_same_job(job, surface_name, center_cx, center_cy, force_name, max_ring)
  return job.surface_name == surface_name
     and job.center_cx == center_cx
     and job.center_cy == center_cy
     and job.force_name == force_name
     and job.max_ring == max_ring
end

function S.enqueue(surface, center_pos, force_name, radius_tiles)
  expect_storage()
  radius_tiles = radius_tiles or 640

  local surface_name = surface.name
  local center_cx, center_cy = chunk_xy_from_pos(center_pos)
  local max_ring = math.ceil(radius_tiles / CHUNK_SIZE)

  for _, job in ipairs(storage.bd_pet_chart_jobs) do
    if is_same_job(job, surface_name, center_cx, center_cy, force_name, max_ring) then
      return false
    end
  end

  table.insert(storage.bd_pet_chart_jobs, {
    surface_name = surface_name,
    force_name = force_name,
    center_cx = center_cx,
    center_cy = center_cy,
    max_ring = max_ring,
    ring = 0,
    ring_i = 0,
    created_tick = game.tick,
  })

  return true
end

function S.process_step(max_jobs_per_tick, chunks_per_job)
  expect_storage()
  max_jobs_per_tick = max_jobs_per_tick or 1
  chunks_per_job = chunks_per_job or 12

  if #storage.bd_pet_chart_jobs == 0 then return 0 end

  local processed = 0
  local jobs_processed = 0

  local idx = 1
  while idx <= #storage.bd_pet_chart_jobs and jobs_processed < max_jobs_per_tick do
    local job = storage.bd_pet_chart_jobs[idx]

    local surface = game.surfaces[job.surface_name]
    local force = game.forces[job.force_name]

    if not surface or not force then
      table.remove(storage.bd_pet_chart_jobs, idx)
    else
      local chunks_done = 0

      while chunks_done < chunks_per_job do
        if job.ring > job.max_ring then
          break
        end

        local dx, dy = ring_point(job.ring, job.ring_i)
        local cx = job.center_cx + dx
        local cy = job.center_cy + dy

        chart_chunk(force, surface, cx, cy)

        processed = processed + 1
        chunks_done = chunks_done + 1

        if job.ring == 0 then
          job.ring = 1
          job.ring_i = 0
        else
          job.ring_i = job.ring_i + 1
          if job.ring_i >= (8 * job.ring) then
            job.ring = job.ring + 1
            job.ring_i = 0
          end
        end

        if job.ring > job.max_ring then
          break
        end
      end

      if job.ring > job.max_ring then
        table.remove(storage.bd_pet_chart_jobs, idx)
      else
        idx = idx + 1
      end

      jobs_processed = jobs_processed + 1
    end
  end

  return processed
end

return S