# source `modules.sh` before attempting to build or run.

CXX = g++

# upcxx-meta PPFLAGS are really CFLAGS to be used during compilation
# upcxx-meta LDFLAGS are really CFLAGS to be used during linking
# upcxx-meta LIBFLAGS are really a combination of LDLIBS and LDFLAGS

CXXFLAGS = `upcxx-meta PPFLAGS` `upcxx-meta LDFLAGS`
LDFLAGS = `upcxx-meta LIBFLAGS`

all: kmer_hash

kmer_hash: kmer_hash.cpp kmer_t.hpp pkmer_t.hpp packing.hpp read_kmers.hpp hash_map.hpp butil.hpp
	$(CXX) kmer_hash.cpp -o kmer_hash $(CXXFLAGS) $(LDFLAGS)

kmer_hash_19: kmer_hash.cpp kmer_t.hpp pkmer_t.hpp packing.hpp read_kmers.hpp hash_map.hpp butil.hpp
	$(CXX) kmer_hash.cpp -o kmer_hash_19 $(CXXFLAGS) $(LDFLAGS) -DKMER_LEN=19

kmer_hash_51: kmer_hash.cpp kmer_t.hpp pkmer_t.hpp packing.hpp read_kmers.hpp hash_map.hpp butil.hpp
	$(CXX) kmer_hash.cpp -o kmer_hash_51 $(CXXFLAGS) $(LDFLAGS) -DKMER_LEN=51

kmer_strong_single_test.dat: kmer_hash_19
	upcxx-run -n 1 -shared-heap 50% ./kmer_hash_19 data/test.txt data > kmer_strong_single_test.dat
	upcxx-run -n 2 -shared-heap 50% ./kmer_hash_19 data/test.txt data >> kmer_strong_single_test.dat
	upcxx-run -n 4 -shared-heap 50% ./kmer_hash_19 data/test.txt data >> kmer_strong_single_test.dat
	upcxx-run -n 8 -shared-heap 50% ./kmer_hash_19 data/test.txt data >> kmer_strong_single_test.dat

clean:
	@rm -fv kmer_hash kmer_hash_19 kmer_hash_51
