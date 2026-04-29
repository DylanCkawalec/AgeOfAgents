// Copyright 2023-2024 the openage authors. See copying.md for legal info.

#include "engine.h"

#include "log/log.h"
#include "log/message.h"

#include "cvar/cvar.h"
#include "gamestate/simulation.h"
#include "presenter/presenter.h"
#include "time/time_loop.h"


namespace openage::engine {

Engine::Engine(mode mode,
               const util::Path &root_dir,
               const std::vector<std::string> &mods,
               const renderer::window_settings &window_settings) :
	running{true},
	run_mode{mode},
	root_dir{root_dir},
	threads{},
	window_settings{window_settings} {
	log::log(INFO
	         << "launching engine with root directory"
	         << root_dir);

	// read and apply the configuration files
	this->cvar_manager = std::make_shared<cvar::CVarManager>(this->root_dir["cfg"]);
	cvar_manager->load_all();

	// time loop
	this->time_loop = std::make_shared<time::TimeLoop>();

	// game simulation
	this->simulation = std::make_shared<gamestate::GameSimulation>(this->root_dir,
	                                                               this->cvar_manager,
	                                                               this->time_loop);
	this->simulation->set_modpacks(mods);

	// Initialize the simulation up front so that the presenter (which now
	// runs on the main thread for macOS Cocoa Qt compatibility) can safely
	// call simulation->attach_renderer() during init_graphics without racing
	// the simulation thread on `this->game` creation.
	this->simulation->start();

	// presenter (optional)
	if (this->run_mode == mode::FULL) {
		this->presenter = std::make_shared<presenter::Presenter>(this->root_dir,
		                                                         this->simulation,
		                                                         this->time_loop);
	}

	// FULL mode no longer spawns dedicated time-loop or simulation threads.
	// The presenter (running on the process main thread, as required by macOS
	// Cocoa Qt) drives the clock and the simulation step inline each frame,
	// matching the proven Pong demo pattern. Headless mode still spawns its
	// own time-loop side thread because the simulation drives the main loop.
	if (this->run_mode != mode::FULL) {
		this->threads.emplace_back([&]() {
			this->time_loop->run();
			this->time_loop.reset();
		});
	}
	else {
		// Start the clock now so the presenter's first frame can advance time.
		this->time_loop->start();
	}

	log::log(INFO << "Using " << this->threads.size() + 1 << " threads "
	              << "(" << std::jthread::hardware_concurrency() << " available)");
}

void Engine::loop() {
	if (this->run_mode == mode::FULL && this->presenter) {
		// GUI toolkits (notably Qt on macOS Cocoa) require their event loop on
		// the process main thread, so the presenter is driven from here.
		// The presenter's draw loop also drives `simulation->step()` so the
		// gameplay simulation runs on the same thread as the renderer.
		this->presenter->run(this->window_settings);

		// Destruct the presenter on the main thread so OpenGL contexts are
		// torn down where they were created.
		this->presenter.reset();
		this->simulation.reset();
		this->running = false;

		return;
	}

	// Headless / legacy modes: drive the simulation on the main thread.
	this->simulation->run();
	this->simulation.reset();
	this->running = false;
}

} // namespace openage::engine
