#pragma once

#include <upcxx/upcxx.hpp>

#include "kmer_t.hpp"

struct HashMap {
	upcxx::dist_object<std::vector<upcxx::global_ptr<kmer_pair>>> data;
	upcxx::global_ptr<unsigned> used;
	upcxx::atomic_domain<unsigned> ad;

	size_t my_size;

	size_t size() const noexcept;

	HashMap(size_t size);

	// Most important functions: insert and retrieve
	// k-mers from the hash table.
	bool insert(const kmer_pair &kmer);
	bool find(const pkmer_t &key_kmer, kmer_pair &val_kmer);

	// Helper functions

	// Write and read to a logical data slot in the table.
	void write_slot(uint64_t slot, const kmer_pair &kmer);
	kmer_pair read_slot(uint64_t slot);

	// Request a slot or check if it's already used.
	bool request_slot(uint64_t slot);
	bool slot_used(uint64_t slot);
};

HashMap::HashMap(size_t size)
    : my_size(size),
      data(std::vector<upcxx::global_ptr<kmer_pair>>(size)),
      ad({upcxx::atomic_op::compare_exchange}) {
	if (upcxx::rank_me() == 0) {
		used = upcxx::new_array<unsigned>(size);
		for (unsigned i = 0; i < size; i++) { used.local()[i] = 0; }
	}

	used = upcxx::broadcast(used, 0).wait();
}

bool HashMap::insert(const kmer_pair &kmer) {
	uint64_t hash  = kmer.hash();
	uint64_t probe = 0;
	bool success   = false;
	do {
		uint64_t slot = (hash + probe++) % size();
		success       = request_slot(slot);
		if (success) { write_slot(slot, kmer); }
	} while (!success && probe < size());
	return success;
}

bool HashMap::find(const pkmer_t &key_kmer, kmer_pair &val_kmer) {
	uint64_t hash  = key_kmer.hash();
	uint64_t probe = 0;
	bool success   = false;
	do {
		uint64_t slot = (hash + probe++) % size();
		if (slot_used(slot)) {
			val_kmer = read_slot(slot);
			if (val_kmer.kmer == key_kmer) { success = true; }
		}
	} while (!success && probe < size());
	return success;
}

bool HashMap::slot_used(uint64_t slot) {
	return upcxx::rget(used + slot).wait();
}

void HashMap::write_slot(uint64_t slot, const kmer_pair &kmer) {
	(*data)[slot] = upcxx::new_<kmer_pair>(kmer);
	for (unsigned i = 0; i < upcxx::rank_n(); i++) {
		if (i == upcxx::rank_me()) continue;

		upcxx::rpc(
		    i,
		    [](upcxx::dist_object<std::vector<upcxx::global_ptr<kmer_pair>>> &local_data,
		       uint64_t slot, upcxx::global_ptr<kmer_pair> ptr) { (*local_data)[slot] = ptr; },
		    data, slot, (*data)[slot]);
	}
}

kmer_pair HashMap::read_slot(uint64_t slot) {
	return upcxx::rget((*data)[slot]).wait();
}

bool HashMap::request_slot(uint64_t slot) {
	return ad.compare_exchange(used + slot, 0, 1, std::memory_order_relaxed).wait() == 0;
}

size_t HashMap::size() const noexcept {
	return my_size;
}
