/* Streaming adaptation of tinf 1.2.1; see tinf_stream.c for its license. */
#pragma once
#ifdef __cplusplus
extern "C" {
#endif
struct tinf_reader;
struct tinf_reader *tinf_reader_open(void *, int (*read_byte)(void *), unsigned output_limit);
int tinf_reader_read(struct tinf_reader *, unsigned char *, unsigned length);
int tinf_reader_finish(struct tinf_reader *);
void tinf_reader_close(struct tinf_reader *);
int tinf_stream(void *context, int (*read_byte)(void *),
                int (*write_bytes)(void *, const unsigned char *, unsigned),
                unsigned output_limit);
#ifdef __cplusplus
}
#endif
