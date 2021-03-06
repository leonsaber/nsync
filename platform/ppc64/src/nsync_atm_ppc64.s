/* Copyright 2016 Google Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. */

/* Helper routines for ppc64 implementation of atomic operations. */

	.text

/* Atomically:
        int nsync_atm_cas_ (nsync_atomic_uint32_ *p, uint32_t old_value, uint32_t new_value) {
                if (*p == old_value) {
                        *p = new_value;
                        return (some-non-zero-value);
                } else {
                        return (0);
                }
        }
 */
	.align	3
	.global	nsync_atm_cas_
	.type	nsync_atm_cas_, %function
nsync_atm_cas_:
1:
	lwarx   %r6,0,%r3
	cmpw    %r4,%r6
	bne     2f
	stwcx.  %r5,0,%r3
	bne     1b
	li      %r3,1
	blr
2:
	li      %r3,0
	blr

/* Like nsync_atm_cas_, but with acquire barrier semantics. */
	.align	3
	.global	nsync_atm_cas_acq_
	.type	nsync_atm_cas_acq_, %function
nsync_atm_cas_acq_:
1:
	lwarx   %r6,0,%r3
	cmpw    %r4,%r6
	bne     2f
	stwcx.  %r5,0,%r3
	bne     1b
	li      %r3,1
	lwsync
	blr
2:
	li      %r3,0
	blr

/* Like nsync_atm_cas_, but with release barrier semantics. */
	.align	3
	.global	nsync_atm_cas_rel_
	.type	nsync_atm_cas_rel_, %function
nsync_atm_cas_rel_:
	lwsync
1:
	lwarx   %r6,0,%r3
	cmpw    %r4,%r6
	bne     2f
	stwcx.  %r5,0,%r3
	bne     1b
	li      %r3,1
	blr
2:
	li      %r3,0
	blr

/* Like nsync_atm_cas_, but with both acquire and release barrier semantics. */
	.align	3
	.global	nsync_atm_cas_relacq_
	.type	nsync_atm_cas_relacq_, %function
nsync_atm_cas_relacq_:
	lwsync
1:
	lwarx   %r6,0,%r3
	cmpw    %r4,%r6
	bne     2f
	stwcx.  %r5,0,%r3
	bne     1b
	li      %r3,1
	lwsync
	blr
2:
	li      %r3,0
	blr

/* Atomically:
        uint32_t nsync_atm_load_ (nsync_atomic_uint32_ *p) { return (*p); } */
	.align	3
	.global	nsync_atm_load_
	.type	nsync_atm_load_, %function
nsync_atm_load_:
	lwz     %r3,0(%r3)
	blr

/* Like nsync_atm_load_, but with acquire barrier semantics. */
	.align	3
	.global	nsync_atm_load_acq_
	.type	nsync_atm_load_acq_, %function
nsync_atm_load_acq_:
	lwz     %r3,0(%r3)
	lwsync
	blr

/* Atomically:
        void nsync_atm_store_ (nsync_atomic_uint32_ *p, uint32_t value) { *p = value; } */
	.align	3
	.global	nsync_atm_store_
	.type	nsync_atm_store_, %function
nsync_atm_store_:
	stw     %r4,0(%r3)
	blr

/* Like nsync_atm_store_, but with release barrier semantics. */
	.align	3
	.global	nsync_atm_store_rel_
	.type	nsync_atm_store_rel_, %function
nsync_atm_store_rel_:
	lwsync
	stw     %r4,0(%r3)
	blr
