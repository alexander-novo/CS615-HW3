#pragma once

#include <upcxx/upcxx.hpp>

#include "kmer_t.hpp"

struct HashMap {
	// Vector of pointers to data. One pointer for each process,
	// but each pointer points to an array of sizePerProcess elements,
	// so elements are distributed accross processes
	std::vector<upcxx::global_ptr<kmer_pair>> data;
	// Vector of 'used' flags which keep track of which slots in data
	// contain valid data. Global pointers for the purpose of atomic
	// operations. 0 if the element is unused, 1 otherwise.
	std::vector<upcxx::global_ptr<unsigned>> used;
	// The number of elements pointed to by each data/used pointer
	size_t sizePerProcess;
	// An atomic domain for accessing the used flags atomically
	upcxx::atomic_domain<unsigned> ad;

	// total # of elements in the hashmap
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
      data(upcxx::rank_n()),
      used(upcxx::rank_n()),
      ad({upcxx::atomic_op::compare_exchange}) {
	// Divide up k-mers among processes.
	sizePerProcess = upcxx::rank_n() > 1 ? (size + upcxx::rank_n() - 1) / upcxx::rank_n() : size;
	auto kmer_ptr  = upcxx::new_array<kmer_pair>(sizePerProcess);
	auto used_ptr  = upcxx::new_array<unsigned>(sizePerProcess);

	upcxx::future<> fut_all = upcxx::make_future();
	for (unsigned i = 0; i < upcxx::rank_n(); i++) {
		fut_all = upcxx::when_all(
		    fut_all,
		    (upcxx::future<>) upcxx::broadcast(kmer_ptr, i)
		        .then([this, i](const upcxx::global_ptr<kmer_pair> &val) { data[i] = val; }),
		    (upcxx::future<>) upcxx::broadcast(used_ptr, i)
		        .then([this, i](const upcxx::global_ptr<unsigned> &val) { used[i] = val; }));
	}

	fut_all.wait();
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
	bool success   = false, fullSlot;

	do {
		uint64_t slot = (hash + probe++) % size();
		fullSlot      = slot_used(slot);
		if (fullSlot) {
			val_kmer = read_slot(slot);
			if (val_kmer.kmer == key_kmer) { success = true; }
		}
	} while (!success && probe < size() && fullSlot);
	return success;
}

bool HashMap::slot_used(uint64_t slot) {
	return upcxx::rget(used[slot / sizePerProcess] + (slot % sizePerProcess)).wait();
}

void HashMap::write_slot(uint64_t slot, const kmer_pair &kmer) {
	upcxx::rput(kmer, data[slot / sizePerProcess] + (slot % sizePerProcess));
}

kmer_pair HashMap::read_slot(uint64_t slot) {
	return upcxx::rget(data[slot / sizePerProcess] + (slot % sizePerProcess)).wait();
}

bool HashMap::request_slot(uint64_t slot) {
	// Expect the value of 0 and set to 1. If it returns 0, it means that the slot was unused
	// and we have succesfully requested it.
	return ad.compare_exchange(used[slot / sizePerProcess] + (slot % sizePerProcess), 0, 1,
	                           std::memory_order_relaxed)
	           .wait() == 0;
}

size_t HashMap::size() const noexcept {
	return my_size;
}
