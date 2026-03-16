package com.hibi.server.domain.search.service;

import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.artistfollow.repository.ArtistFollowRepository;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.follow.repository.MemberFollowRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.search.dto.response.*;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.SongRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SearchService {

    private final SongRepository songRepository;
    private final ArtistRepository artistRepository;
    private final FeedPostRepository feedPostRepository;
    private final MemberRepository memberRepository;
    private final ArtistFollowRepository artistFollowRepository;
    private final MemberFollowRepository memberFollowRepository;

    private static final int DEFAULT_LIMIT = 10;
    private static final int MAX_LIMIT = 50;

    /**
     * 통합 검색
     */
    public SearchResponse search(String keyword, String category, Integer limit) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return SearchResponse.empty("");
        }

        String trimmedKeyword = keyword.trim();
        int effectiveLimit = getEffectiveLimit(limit);

        return switch (category != null ? category.toLowerCase() : "all") {
            case "songs" -> searchSongsOnly(trimmedKeyword, effectiveLimit);
            case "artists" -> searchArtistsOnly(trimmedKeyword, effectiveLimit);
            case "posts" -> searchPostsOnly(trimmedKeyword, effectiveLimit);
            case "users" -> searchUsersOnly(trimmedKeyword, effectiveLimit);
            default -> searchAll(trimmedKeyword, effectiveLimit);
        };
    }

    private int getEffectiveLimit(Integer limit) {
        if (limit == null || limit <= 0) {
            return DEFAULT_LIMIT;
        }
        return Math.min(limit, MAX_LIMIT);
    }

    private SearchResponse searchAll(String keyword, int limit) {
        List<SearchSongResponse> songs = searchSongs(keyword, limit);
        List<SearchArtistResponse> artists = searchArtists(keyword, limit);
        List<SearchPostResponse> posts = searchPosts(keyword, limit);
        List<SearchUserResponse> users = searchUsers(keyword, limit);

        return SearchResponse.of(keyword, songs, artists, posts, users);
    }

    private SearchResponse searchSongsOnly(String keyword, int limit) {
        List<SearchSongResponse> songs = searchSongs(keyword, limit);
        return SearchResponse.of(keyword, songs, List.of(), List.of(), List.of());
    }

    private SearchResponse searchArtistsOnly(String keyword, int limit) {
        List<SearchArtistResponse> artists = searchArtists(keyword, limit);
        return SearchResponse.of(keyword, List.of(), artists, List.of(), List.of());
    }

    private SearchResponse searchPostsOnly(String keyword, int limit) {
        List<SearchPostResponse> posts = searchPosts(keyword, limit);
        return SearchResponse.of(keyword, List.of(), List.of(), posts, List.of());
    }

    private SearchResponse searchUsersOnly(String keyword, int limit) {
        List<SearchUserResponse> users = searchUsers(keyword, limit);
        return SearchResponse.of(keyword, List.of(), List.of(), List.of(), users);
    }

    private List<SearchSongResponse> searchSongs(String keyword, int limit) {
        List<Song> songs = songRepository.searchByKeyword(keyword);
        return songs.stream()
                .limit(limit)
                .map(SearchSongResponse::from)
                .collect(Collectors.toList());
    }

    private List<SearchArtistResponse> searchArtists(String keyword, int limit) {
        List<Artist> artists = artistRepository.searchByKeyword(keyword);
        return artists.stream()
                .limit(limit)
                .map(artist -> {
                    long followerCount = artistFollowRepository.countByArtistId(artist.getId());
                    return SearchArtistResponse.from(artist, followerCount);
                })
                .collect(Collectors.toList());
    }

    private List<SearchPostResponse> searchPosts(String keyword, int limit) {
        List<FeedPost> posts = feedPostRepository.searchByKeyword(keyword);
        return posts.stream()
                .limit(limit)
                .map(SearchPostResponse::from)
                .collect(Collectors.toList());
    }

    private List<SearchUserResponse> searchUsers(String keyword, int limit) {
        List<Member> members = memberRepository.searchByKeyword(keyword);
        return members.stream()
                .limit(limit)
                .map(member -> {
                    long followerCount = memberFollowRepository.countFollowersByUserId(member.getId());
                    return SearchUserResponse.from(member, followerCount);
                })
                .collect(Collectors.toList());
    }
}
